class Api::V1::Accounts::AttachFilesController < Api::V1::Accounts::BaseController
  def create
    file_blob = file_object
    file_blob.save!
    render json: { file_url: url_for(file_blob) }
  end

  def upload
    file_blob = file_object
    render json: { blob_key: file_blob.key, blob_id: file_blob.id }
  end

  def file_object
    ActiveStorage::Blob.create_and_upload!(
      key: nil,
      io: params[:image].tempfile,
      filename: params[:image].original_filename,
      content_type: params[:image].content_type
    )
  end
end
