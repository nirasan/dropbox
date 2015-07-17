class Node < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, UploadFileUploader
end
