
use_inline_resources

action :create do
  converge_by('Creating Traffic Manager') do
    traffic_manager_processor = TrafficManagers.new(@new_resource.resource_group_name,
                                                  @new_resource.profile_name,
                                                  @new_resource.subscription,
                                                  @new_resource.traffic_manager,
                                                  @new_resource.azure_token)
    node.set['status_code'] = traffic_manager_processor.create_update_profile
  end
  @new_resource.updated_by_last_action(true)
end

action :delete do
  converge_by('Deleting Traffic Manager') do
    traffic_manager_processor = TrafficManagers.new(@new_resource.resource_group_name,
                                                  @new_resource.profile_name,
                                                  @new_resource.subscription,
                                                  @new_resource.traffic_manager,
                                                  @new_resource.azure_token)
    node.set['status_code'] = traffic_manager_processor.delete_profile
  end
  @new_resource.updated_by_last_action(true)
end
