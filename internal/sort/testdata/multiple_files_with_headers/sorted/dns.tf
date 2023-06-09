/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
 Creates DNS Peering to DNS HUB
*****************************************/

data "google_compute_network" "vpc_dns_hub" {
  name    = "vpc-c-dns-hub"
  project = var.dns_hub_project_id
}

module "peering_zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 5.0"

  description = "Private DNS peering zone."
  domain      = var.domain
  name        = "dz-${var.environment_code}-shared-base-to-dns-hub"
  private_visibility_config_networks = [
    module.main.network_self_link
  ]
  project_id     = var.project_id
  target_network = data.google_compute_network.vpc_dns_hub.self_link
  type           = "peering"
}

/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  enable_inbound_forwarding = var.dns_enable_inbound_forwarding
  enable_logging            = var.dns_enable_logging
  name                      = "dp-${var.environment_code}-shared-base-default-policy"

  networks {
    network_url = module.main.network_self_link
  }

  project = var.project_id
}
