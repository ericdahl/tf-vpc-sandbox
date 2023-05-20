resource "aws_networkfirewall_rule_group" "stateless" {
  name     = "stateless"
  type     = "STATELESS"
  capacity = 100


  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {


#        stateless_rule {
#          priority = 2
#
#          rule_definition {
#            actions = [
#              "aws:pass",
#            ]
#
#            match_attributes {
#              protocols = [
#                6,
#              ]
#
#              destination {
#                address_definition = "93.184.216.34/32"
#              }
#
#              destination_port {
#                from_port = 80
#                to_port   = 80
#              }
#
#              source {
#                address_definition = "10.1.0.0/16"
#              }
#
#              source_port {
#                from_port = 0
#                to_port   = 65535
#              }
#            }
#          }
#        }
#
#        stateless_rule {
#          priority = 3
#
#          rule_definition {
#            actions = [
#              "aws:pass",
#            ]
#
#            match_attributes {
#              protocols = [
#                6,
#              ]
#
#              destination {
#                address_definition = "10.1.0.0/16"
#              }
#
#              destination_port {
#                from_port = 0
#                to_port   = 65535
#              }
#
#              source {
#                address_definition = "93.184.216.34/32"
#              }
#
#              source_port {
#                from_port = 80
#                to_port   = 80
#              }
#            }
#          }
#        }


                stateless_rule {
                  priority = 3

                  rule_definition {
                    actions = [
                      "aws:pass",
                    ]

                    match_attributes {
                      protocols = [
                        6,
                      ]



                      source {
                        address_definition = "93.184.216.34/32"
                      }


                    }
                  }
                }

        stateless_rule {
          priority = 4

          rule_definition {
            actions = [
              "aws:pass",
            ]

            match_attributes {
              protocols = [
                6,
              ]

              destination {
                address_definition = "93.184.216.34/32"
              }



            }
          }
        }


        stateless_rule {
          priority = 10

          rule_definition {
            actions = [
              "aws:drop",
            ]

            match_attributes {
              protocols = [
                6,
              ]

              destination {
                address_definition = "0.0.0.0/0"
              }

              destination_port {
                from_port = 80
                to_port   = 80
              }

              source {
                address_definition = "0.0.0.0/0"
              }

              source_port {
                from_port = 0
                to_port   = 65535
              }
            }
          }
        }

      }
    }
  }
}

