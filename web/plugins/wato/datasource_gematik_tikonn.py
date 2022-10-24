#!/usr/bin/env python3
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

from cmk.gui.i18n import _
from cmk.gui.plugins.wato import (
    HostRulespec,
    IndividualOrStoredPassword,
    rulespec_registry,
)
from cmk.gui.valuespec import (
    Dictionary,
    NetworkPort,
    TextInput,
    DropdownChoice,
    Tuple,
    ListOfStrings,
    FixedValue,
    Transform,
    Alternative,
)

from cmk.gui.log import logger

# FIXME: Dokumentation versch. Rulespecs!
from cmk.gui.plugins.wato.datasource_programs import (
    RulespecGroupDatasourceProgramsHardware,
)

# TODO: Aufräiumen
# def _item_valuespec_foobar():
#    return TextAscii(title=_("Sector name"))


def forth(data):
    if not "verify_ssl" in data:
        # logger.critical("BEFORE: " + str(data))
        data["verify_ssl"] = True
        # logger.critical("AFTER: " + str(data))
    return data


def _transform_valuespec_special_agents_gematik_tikonn():
    return Transform(_valuespec_special_agents_gematik_tikonn(), forth=forth)


def _valuespec_special_agents_gematik_tikonn():
    return Dictionary(
        title=_("Gematik TI-Konnektor"),
        help=_(
            """Überwachung der Gematik-konformen Konnektoren zur sicheren Anbindung von
Clientsystemen der Institutionen und Organisationen des Gesundheitswesens an die
Telematikinfrastruktur."""
        ),
        elements=[
            (
                "port",
                NetworkPort(
                    title=_("Port"),
                    help=_("Netzwerkport des Konnektors"),
                    default_value=80,
                ),
            ),
            (
                "verify_ssl",
                # Transform(
                Alternative(
                    title=_("Gültigkeit des SSL-Zertifikats"),
                    default_value=True,
                    elements=[
                        FixedValue(True, title=_("überprüfen"), totext=""),
                        FixedValue(False, title=_("nicht überprüfen"), totext=""),
                    ],
                ),
                # forth=lambda v: v if isinstance(v, dict) else {""}),
                #    forth=forth,
                # ),
            ),
            (
                "wsdl_versions",
                Tuple(
                    title=_("WSDL-Versionen"),
                    help=_(
                        """Versionen der einzelnen Endpunkt-WSDLs.<br>
                        Da die TI-Konnektoren das WSDL nicht selbst ausliefern, ist 
                        es im MKP des Special Agents enthalten und wird vom Filesystem gelesen. <br>                
                        Die jeweils passende Version kann ermittelt werden über die SDS des 
                        connectors, üblicherweise erreichbar über http://konnektor:80/connector.sds,
                        und kann dann hier eingestellt werden.
                        """
                    ),
                    elements=[
                        DropdownChoice(
                            title=_("EventService"),
                            help=_(
                                "WSDL-Version des Systeminformationservice (EventService)"
                            ),
                            sorted=True,
                            choices=[
                                ("7.2.0", _("v7.2.0")),
                                ("7.1.0", _("v7.1.0")),
                            ],
                            default_value="7.2.0",
                        ),
                        DropdownChoice(
                            title=_("SignatureService"),
                            help=_(
                                "WSDL-Version des Signaturdienstes (SignatureService)"
                            ),
                            sorted=True,
                            choices=[
                                ("7.4.0", _("v7.4.0")),
                                ("7.4.2", _("v7.4.2")),
                                ("7.5.5", _("v7.5.5")),
                            ],
                            default_value="7.5.5",
                        ),
                    ],
                ),
            ),
            (
                "mandant_id",
                TextInput(
                    title=_("Mandant-ID"),
                    # help=_("Mandanten-Identifikationsnummer"),
                    allow_empty=False,
                ),
            ),
            (
                "client_id",
                TextInput(
                    title=_("Client-ID"),
                    # help=_("Client-Identifikationsnummer"),
                    allow_empty=False,
                ),
            ),
            (
                "workplace_ids",
                ListOfStrings(
                    title=_("Zugeordnete Arbeitsstationen"),
                    orientation="horizontal",
                    allow_empty=False,
                ),
            ),
        ],
        optional_keys=["token"],
    )


# gematik
rulespec_registry.register(
    (
        HostRulespec(
            group=RulespecGroupDatasourceProgramsHardware,
            name="special_agents:gematik_tikonn",
            valuespec=_transform_valuespec_special_agents_gematik_tikonn,
        )
    )
)
