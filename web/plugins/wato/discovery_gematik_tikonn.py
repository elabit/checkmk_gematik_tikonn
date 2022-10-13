#!/usr/bin/env python3
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

from cmk.gui.i18n import _
from cmk.gui.valuespec import (
    DropdownChoice,
    Checkbox,
    Dictionary,
    ListOf,
    TextAscii,
    Tuple,
    TextUnicode,
)

from cmk.gui.plugins.wato import (
    rulespec_registry,
    RulespecGroupCheckParametersDiscovery,
    HostRulespec,
)
from pyrsistent import optional


def _valuespec_inventory_gematik_tikonn():
    return Dictionary(
        title=_("Gematik TI-Konnektor"),
        elements=[
            ("vpn", _valuespec_tuple_vpn()),
            ("peripherie", _valuespec_tuple_peripherie()),
        ],
        optional_keys=False,
    )


def _valuespec_tuple_peripherie():
    return Tuple(
        title=_("Peripherie"),
        elements=[
            Checkbox(
                label=_("Arbeitsstationen"),
                default_value=True,
                help=_("""Listet alle angeschlossenen Arbeitsstationen auf."""),
            ),
            Checkbox(
                label=_("Kartenterminals"),
                default_value=True,
                help=_("""Listet alle angeschlossenen Kartenterminals auf."""),
            ),
        ],
    )


def _valuespec_tuple_vpn():
    return Tuple(
        title=_("VPN-Verbindungen"),
        elements=[
            Checkbox(
                label=_("TI-VPN"),
                default_value=True,
                help=_(
                    """Die <b>Telematikinfrastruktur (TI)</b> ist die Plattform für Gesundheitsanwendungen in Deutschland,
                    zu welcher der Konnektor ein VPN aufbaut."""
                ),
            ),
            Checkbox(
                label=_("SIS-VPN (optional)"),
                default_value=False,
                help=_(
                    """Der <b>SIS ("Sicherer InternetService")</b> ist ein zweiter, optionaler Kanal zum Zumgangsdienstbetreiber. <br>
                    Um gegen Bedrohungen aus dem Internet geschützt zu sein, kann der SIS mit besonderen 
                    Sicherheitsfunktionen (z. B. dem Filtern von unerwünschten Webseiten) abgesichert sein."""
                ),
            ),
        ],
    )


rulespec_registry.register(
    HostRulespec(
        group=RulespecGroupCheckParametersDiscovery,
        match_type="dict",
        name="discovery_gematik_tikonn",
        title=lambda: _("Gematik TI-Konnektor"),
        valuespec=_valuespec_inventory_gematik_tikonn,
    )
)
