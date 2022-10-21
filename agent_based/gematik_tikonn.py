# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

from datetime import datetime, timezone

# from tzlocal import get_localzone
import json
import dateutil
from .agent_based_api.v1 import (
    register,
    Result,
    Service,
    State,
)


vpn_item2name = {"VPN (TI)": "VPNTIStatus", "VPN (SIS)": "VPNSISStatus"}
vpn_states = {"Online": 0, "Offline": 2}


def parse_gematik_tikonn(string_table):
    data = {}
    for l in string_table:
        try:
            data.update(json.loads(l[0]))
        except:
            raise Exception()
    return data


register.agent_section(
    name="gematik_tikonn",
    parse_function=parse_gematik_tikonn,
)


def discovery_gematik_tikonn(params, section):
    vpnti = params["vpn"][0]
    vpnsis = params["vpn"][1]
    wp = params["peripherie"][0]
    ct = params["peripherie"][1]
    if vpnti == True and "VPNTIStatus" in section:
        yield Service(item="VPN (TI)")
        # yield Service()
    if vpnsis == True and "VPNSISStatus" in section:
        yield Service(item="VPN (SIS)")
    if wp == True:
        yield Service(item="Arbeitsstationen")
    if ct == True:
        yield Service(item="Kartenterminals")


def check_gematik_tikonn(item, params, section):
    if item.startswith("VPN"):
        vpn = section.get(vpn_item2name[item], False)
        # Connection Status
        vpn_status = State(vpn_states[vpn["ConnectionStatus"]])
        # Connection time
        LOCAL_TZ = datetime.now(timezone.utc).astimezone().tzinfo
        vpn_connected_time = dateutil.parser.parse(vpn["Timestamp"]).astimezone(
            LOCAL_TZ
        )
        vpn_connected_time_str = vpn_connected_time.strftime("%H:%M Uhr (%d.%m.%Y)")
        # Siehe Spezifikation, TAB_KON_568
        yield Result(
            state=vpn_status,
            summary="{} ist {} - Letzte Statusänderung: {}".format(
                item, vpn["ConnectionStatus"], vpn_connected_time_str
            ),
        )
    elif item == "Arbeitsstationen":
        if "wp" in section and "wp_faulty" in section:
            wp_faulty = section["wp_faulty"]
            wp_ok = section["wp"]
            out_fault = ""
            if wp_faulty:
                out_fault = " - Kontextfehler bei: {} (!)".format(", ".join(wp_faulty))
            yield Result(
                state=State(int(bool(len(wp_faulty)))),
                summary="OK: {}{}".format(", ".join(wp_ok), out_fault),
            )

    elif item == "Kartenterminals":
        card_terminals = section.get("card_terminals", None)
        yield Result(state=State(0), summary=", ".join(card_terminals))


register.check_plugin(
    name="gematik_tikonn",
    service_name="TI-Konnektor %s",
    discovery_function=discovery_gematik_tikonn,
    # Default: TI=ja, SIS=nein
    discovery_default_parameters={"vpn": (True, False)},
    discovery_ruleset_name="discovery_gematik_tikonn",
    check_function=check_gematik_tikonn,
    # check_ruleset_name="check_params_gematik_tikonn",
    check_default_parameters={},
)

#################################################################################
#################################################################################


def parse_gematik_cardterminal(string_table):
    data = {}
    for l in string_table:
        try:
            data.update(json.loads(l[0]))
        except:
            raise Exception()
    return data


register.agent_section(
    name="gematik_cardterminal",
    parse_function=parse_gematik_cardterminal,
)


def discovery_gematik_cardterminal(params, section):

    yield Service(item="Sysinfo")


def check_gematik_cardterminal(item, params, section):
    prodinfo = section["ProductInformation"]
    id = section["CtId"]
    workplaces = ", ".join(section["WorkplaceIds"].get("WorkplaceId", ""))
    ip4address = section["IPAddress"].get("IPV4Address", "n.d.")
    ip6address = section["IPAddress"].get("IPV6Address", "n.d.")
    ips = "IPv4: {}/IPv6: {}".format(ip4address, ip6address)
    out = "Arbeitsplatz '{}', ID: '{}', {}".format(workplaces, id, ips)

    yield Result(state=State(0), summary=out)


register.check_plugin(
    name="gematik_cardterminal",
    service_name="%s",
    discovery_function=discovery_gematik_cardterminal,
    # Default: TI=ja, SIS=nein
    discovery_default_parameters={"vpn": (True, False)},
    discovery_ruleset_name="discovery_gematik_cardterminal",
    check_function=check_gematik_cardterminal,
    # check_ruleset_name="check_params_gematik_cardterminal",
    check_default_parameters={},
)
