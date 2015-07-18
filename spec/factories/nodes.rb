FactoryGirl.define do
  factory :node do
    user nil
    name "MyText"
    parent_node_id 1
    is_folder false
    is_root false
  end

end
