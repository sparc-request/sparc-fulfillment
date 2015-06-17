class DocumentsController < ApplicationController

  before_action :find_document, only: [:show]
  before_action :authorize_document_access, only: [:show]
  before_action :validate_presence_of_upload, only: [:create]
  after_action  :mark_document_as_accessed, only: [:show]

  def index
    respond_to do |format|
      format.html { render }
      format.js {
        find_documentable

        @documents = @documentable.documents
        @documentable_id = document_params[:documentable_id]
        @documentable_type = document_params[:documentable_type]
        @documentable_sym = @documentable_type.downcase.to_sym
      }
      format.json {
        @documents = current_identity.documents
      }
    end
  end

  def show
    send_data File.read(@document.path),
      type: @document.content_type,
      disposition: "attachment; filename=#{@document.original_filename}"
  end

  def new
    respond_to do |format|
      format.js {
        @document = Document.new(document_params)
      }
    end
  end

  def create
    respond_to do |format|
      format.js {
        @document = Document.create(document_params.merge!(original_filename: params[:document][:document].original_filename,
                                                           content_type: params[:document][:document].content_type))

        create_document_file

        flash[:success] = t(:documents)[:flash_messages][:created]
      }
    end
  end

  private

  def validate_presence_of_upload
    unless params[:document][:document].present?
      @error = t(:documents)[:flash_messages][:no_file_chosen]

      render
    end
  end

  def create_document_file
    uploaded_io = params[:document][:document]

    File.open(@document.path, 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

  def find_documentable
    @documentable = params[:document][:documentable_type].constantize.find params[:document][:documentable_id]
  end

  def find_document
    @document = Document.find(params[:id])
  end

  def authorize_document_access
    render nothing: true unless @document.accessible_by?(current_identity)
  end

  def mark_document_as_accessed
    update_identity_unaccessed_documents_counter
    @document.update_attributes last_accessed_at: Time.current
  end

  def update_identity_unaccessed_documents_counter
    if !@document.downloaded? && @document.belongs_to_identity?
      current_identity.update_counter :unaccessed_documents, -1
    end
  end

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id, :title)
  end
end
