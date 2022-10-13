#!/bin/env python
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

# This script was/is used to have the github repo cloned into the dev
# CMK site and then deploy the files to the site. 

from pathlib import Path
import os
import shutil

project_root = Path(__file__).parent
omd_root = Path(os.getenv("OMD_ROOT"))
cmk_custom_share = omd_root / "local/share/check_mk"
cmk_custom_agent_based = omd_root / "local/lib/check_mk/base/plugins/agent_based"

share_patterns = [
    "agents/special/agent_*",
    "checks/agent_*",
    "web/plugins/wato/datasource_*",
    "web/plugins/wato/discovery_*",
    "web/plugins/wato/check_parameters_*",
]

for p in share_patterns:
    files = project_root.glob(p)
    for file in files:
        rel_path = file.relative_to(project_root)
        dest_path = cmk_custom_share / file.relative_to(project_root)
        print("{} -> {}".format(str(rel_path), str(dest_path)))
        shutil.copy(str(file), dest_path)

# AGENT BASED
agent_based_pattern = "agent_based/*"
files = project_root.glob(agent_based_pattern)
for file in files:
    rel_path = file.relative_to(project_root)
    print("{} -> {}".format(str(rel_path), str(cmk_custom_agent_based)))
    shutil.copy(str(file), cmk_custom_agent_based)

# Not used anymore. 
# Better clone the WSDL repo on your own from https://github.com/gematik/api-telematik.git
# # WSDL
# wsdl_dir = "lib/wsdl"
# src = project_root / wsdl_dir
# print("{} -> {}".format(str(wsdl_dir), omd_root / "local/lib/wsdl"))
# shutil.copytree(str(src), omd_root / "local/lib/wsdl", dirs_exist_ok=True)
