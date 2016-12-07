require File.expand_path('../../libraries/traffic_managers.rb', __FILE__)

#set the proxy if it exists as a cloud var
Utils.set_proxy(node.workorder.payLoad.OO_CLOUD_VARS)

nsPathParts = node['workorder']['rfcCi']['nsPath'].split('/')
cloud_name = node['workorder']['cloud']['ciName']
dns_attributes = node['workorder']['services']['dns'][cloud_name]['ciAttributes']
subscription = dns_attributes['subscription']

include_recipe 'azure::get_platform_rg_and_as'
resource_group_name = node['platform-resource-group']
resource_group_names = Array.new
resource_group_names.push(resource_group_name)

include_recipe 'azuredns::get_azure_token'
azure_token = node['azure_rest_token']
platform_name = nsPathParts[5]
profile_name = 'trafficmanager-' + platform_name
delete_traffic_manager_action = azuretrafficmanager_traffic_manager 'Traffic Manager' do
  resource_group_name resource_group_name
  profile_name profile_name
  subscription subscription
  traffic_manager traffic_manager
  azure_token azure_token
  action :nothing
end
delete_traffic_manager_action.run_action(:delete)

Chef::Log.info("Exiting Traffic Manager Delete with response status code: " + status_code.to_s)
