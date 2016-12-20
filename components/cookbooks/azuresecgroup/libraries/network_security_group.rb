require 'azure_mgmt_network'
require File.expand_path('../../../azure_base/libraries/logger.rb', __FILE__)

module AzureNetwork
  # this class has all the methods in it to handle Azure's Network Security Group.
  class NetworkSecurityGroup
    include Azure::ARM::Network
    include Azure::ARM::Network::Models

    def initialize(credentials, subscription_id)
      @client = NetworkManagementClient.new(credentials)
      @client.subscription_id = subscription_id
    end

    def get(resource_group_name, network_security_group_name)
      @client.network_security_groups.get(resource_group_name, network_security_group_name)
    rescue MsRestAzure::AzureOperationError => e
      # If the error is that it doesn't exist, return nil
      OOLog.info("Error of Exception is: '#{e.body.values[0]}'")
      OOLog.info("Code of Exception is: '#{e.body.values[0]['code']}'")
      if e.body.values[0]['code'] == 'ResourceNotFound'
        OOLog.info('SECGROUP DOES NOT EXIST!!  Returning nil')
        return nil
      else
        OOLog.fatal("AzureOperationError Exception trying to get network security group #{network_security_group_name} Response: #{e.body}")
      end
    rescue => e
      OOLog.fatal("Azure::Network Security group - Exception trying to get network security group #{network_security_group_name} from resource group: #{resource_group_name}\n\rAzure::Network Security group - Exception is: #{e.message}")
    end

    def create(resource_group_name, net_sec_group_name, location)
      # Creates an empty network security group
      parameters = NetworkSecurityGroup.new
      parameters.location = location

      @client.network_security_groups.create_or_update(resource_group_name, net_sec_group_name, parameters)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError Exception trying to create network security group #{net_sec_group_name} response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to create network security group #{net_sec_group_name} #{e.body} Exception is: #{e.message}")
    end

    def create_update(resource_group_name, net_sec_group_name, parameters)
      @client.network_security_groups.create_or_update(resource_group_name, net_sec_group_name, parameters)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError exception trying to create/update network security group #{net_sec_group_name} Error response: #{e.body}")
    rescue => e
      OOLog.fatal("Azure::Network Security group - Exception trying to create/update network security group #{net_sec_group_name} Exception: #{e.message}")
    end

    def list_security_groups(resource_group_name)
      @client.network_security_groups.list(resource_group_name)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError exception trying to list network security groups from #{resource_group_name} resource group Response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to list network security groups from #{resource_group_name} resource group #{e.body} Exception is: #{e.message}")
    end

    def delete_security_group(resource_group_name, net_sec_group_name)
      @client.network_security_groups.delete(resource_group_name, net_sec_group_name)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.info("AzureOperationError Error deleting NSG #{net_sec_group_name}")
      OOLog.info("Error response: #{e.body}") unless e.body.nil?
    rescue => e
      OOLog.fatal("Exception trying to delete network security group #{net_sec_group_name} Error body: #{e.body} Exception is: #{e.message}")
    end

    def create_or_update_rule(resource_group_name, network_security_group_name, security_rule_name, _security_rule_parameters = nil)
      # The Put network security rule operation creates/updates a security rule in the specified network security group group.
      secrule = SecurityRule.new

      SecurityRules.new(@client).create_or_update(resource_group_name, network_security_group_name, security_rule_name, secrule)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError trying to get the '#{security_rule_name}' Security Rule Response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to create/update security rule #{security_rule_name} #{e.body} Exception is: #{e.message}")
    end

    def delete_rule(resource_group_name, network_security_group_name, security_rule_name)
      # The delete network security rule operation deletes the specified network security rule.
      SecurityRules.new(@client).delete(resource_group_name, network_security_group_name, security_rule_name)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError Error trying to delete the '#{security_rule_name}' Security Rule - Response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to delete security rule #{security_rule_name} #{e.body} Exception is: #{e.message}")
    end

    def get_rule(resource_group_name, network_security_group_name, security_rule_name)
      # The Get NetworkSecurityRule operation retreives information about the specified network security rule.
      SecurityRules.new(@client).get(resource_group_name, network_security_group_name, security_rule_name)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("Error trying to get the '#{security_rule_name}' Security Rule - Response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to get security rule #{security_rule_name} #{e.body} - Exception is: #{e.message}")
    end

    def list_rules(resource_group_name, network_security_group_name)
      # The List network security rule opertion retrieves all the security rules in a network security group.
      SecurityRules.new(@client).list(resource_group_name, network_security_group_name)
    rescue MsRestAzure::AzureOperationError => e
      OOLog.fatal("AzureOperationError Error trying to listing Security Rules in '#{resource_group_name}' Response: #{e.body}")
    rescue => e
      OOLog.fatal("Exception trying to list security rules from securtiry group: #{network_security_group_name} #{e.body} - Exception: #{e.message}")
    end

    def self.create_rule_properties(security_rule_name, access, description, destination_address_prefix, destination_port_range, direction, priority, protocol, provisioning_state, source_address_prefix, source_port_range)
      # 01 @security_rule_name Security group name
      # 02 @access SecurityRuleAccess allow or denied.
      # 03 @description String to 140 chars
      # 04 @destination_address_prefix String source IP range
      # 05 @destination_port_range String range between 0 and 65535.
      # 06 @direction SecurityRuleDirection rule.InBound or Outbound.
      # 07 @priority Integer be between 100 and 4096.
      # 08 @protocol SecurityRuleProtocol applies to.
      # 09 @provisioning_state String resource Updating/Deleting/Failed.
      # 10 @source_address_prefix String range.
      # 11 @source_port_range String between 0 and 65535.

      sec_rule = SecurityRule.new

      sec_rule.name = security_rule_name
      sec_rule.access = access
      sec_rule.description = description
      sec_rule.destination_address_prefix = destination_address_prefix
      sec_rule.destination_port_range = destination_port_range
      sec_rule.direction = direction
      sec_rule.priority = priority
      sec_rule.protocol = protocol
      sec_rule.provisioning_state = provisioning_state
      sec_rule.source_address_prefix = source_address_prefix
      sec_rule.source_port_range = source_port_range
      sec_rule
    end
    # end of class
  end
  # end of module
end
