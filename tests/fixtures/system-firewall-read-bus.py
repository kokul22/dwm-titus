#!/usr/bin/python3
"""Qualify fixed Debian firewall status reads without the host system bus."""

import os
import runpy
import sys
import time
from unittest import mock

os.environ["DBUS_SYSTEM_BUS_ADDRESS"] = os.environ["DBUS_SESSION_BUS_ADDRESS"]
from gi.repository import Gio, GLib

provider = runpy.run_path(sys.argv[1], run_name="firewall_read_fixture")
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
name = "org.freedesktop.systemd1"
path = "/org/freedesktop/systemd1"
units = ("ufw.service", "nftables.service")
mode = "active"
held = []
calls = []
manager = Gio.DBusNodeInfo.new_for_xml("""
<node><interface name="org.freedesktop.systemd1.Manager">
<method name="ListUnitsByNames"><arg type="as" direction="in"/><arg type="a(ssssssouso)" direction="out"/></method>
</interface></node>""").interfaces[0]


def reply(invocation, unit, active="active"):
    absent = mode == "absent"
    load = "not-found" if absent else "loaded"
    state = "inactive" if absent else active
    description = "x" * 70000 if mode == "oversized" else "Fixture firewall"
    unit_path = path + "/unit/" + unit.replace(".", "_")
    row = (unit, description, load, state, "dead", "", unit_path, 0, "", "/")
    invocation.return_value(GLib.Variant(provider["UNIT_REPLY_TYPE"], ([row],)))


def called(_bus, _sender, object_path, interface, method, args, invocation):
    assert (object_path, interface, method) == (path, name + ".Manager", "ListUnitsByNames")
    (requested,) = args.unpack()
    assert len(requested) == 1 and requested[0] in units
    unit = requested[0]
    calls.append(unit)
    if mode == "stall":
        held.append((invocation, unit))
    elif mode in ("denied", "missing"):
        error = "org.freedesktop.DBus.Error.AccessDenied" if mode == "denied" else name + ".NoSuchUnit"
        invocation.return_dbus_error(error, "Private fixture detail")
    else:
        active = "bad\nstate" if mode == "malformed" else mode
        reply(invocation, unit, active)


def read_status():
    start = len(calls)
    reader = provider["FirewallRead"]()
    with mock.patch.dict(provider["read_firewall_status"].__globals__, FirewallRead=lambda: reader):
        result = provider["read_firewall_status"]()
    assert len(calls) == start + 2
    assert set(calls[start:]) == set(units)
    assert reader.done and reader.cancellable.is_cancelled()
    assert not bus.is_closed()
    assert "Private fixture detail" not in repr(result)
    return reader, result


registration = 0
try:
    answer = bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
        "RequestName", GLib.Variant("(su)", (name, 0)), GLib.VariantType.new("(u)"),
        Gio.DBusCallFlags.NONE, 3000, None)
    assert answer.unpack() == (1,)
    registration = bus.register_object(path, manager, called, None, None)
    for mode, status, value in (("active", "available", "enabled"), ("inactive", "available", "disabled"),
            ("failed", "partial", "unknown"), ("activating", "partial", "unknown"),
            ("absent", "unsupported", "unknown"), ("missing", "unsupported", "unknown"),
            ("denied", "unavailable", "unknown"), ("malformed", "partial", "unknown"),
            ("oversized", "partial", "unknown")):
        _reader, result = read_status()
        assert (result.status, result.value) == (status, value), (mode, result)
    mode = "stall"
    started = time.monotonic()
    reader, result = read_status()
    assert 9.5 <= time.monotonic() - started < 15
    assert (result.status, result.value, result.error_code) == ("unavailable", "unknown", "timeout")
    assert len(held) == 2
    saved = reader.failure
    mode = "active"
    for invocation, unit in held:
        reply(invocation, unit)
    held.clear()
    _fresh, result = read_status()
    assert result.value == "enabled"
    assert reader.failure is saved and reader.value is None
    print("Private-bus Debian firewall reads: PASS (fixed units, states, failures, deadline, late reply, shared bus)")
finally:
    for invocation, _unit in held:
        invocation.return_dbus_error("org.freedesktop.DBus.Error.NoReply", "Fixture cleanup")
    if registration:
        bus.unregister_object(registration)
