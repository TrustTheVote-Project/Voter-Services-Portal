class AbsenteeRequest < ActiveRecord::Base
  include Concern::SerializedAttrs
  
  # Identity
  serialized_attr :name_prefix, :first_name, :middle_name, :last_name, :name_suffix
  serialized_attr :dob, :gender, :ssn, :no_ssn, :dmv_id, :no_dmv_id, :id_document_image_type, :id_document_image, :no_doc_image
  serialized_attr :phone, :fax, :email
  
  
end
