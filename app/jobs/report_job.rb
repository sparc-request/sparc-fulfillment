# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ReportJob < ActiveJob::Base

  queue_as :reports

  before_enqueue do
    find_or_create_document_root_path
  end

  def perform(document, params)
    document_name = document.title
    report        = document.report_type.classify.constantize.new(params)

    report.generate(document)

    FayeJob.perform_later document
  end

  rescue_from(StandardError) do |error|
    arguments.first.update_attributes state: 'Error', stack_trace: "#{error.message}\n\n#{error.backtrace.join("\n\t")}"
    FayeJob.perform_later arguments.first
  end

  after_perform do |job|
    job.
      arguments.
      first.
      update_attributes state: 'Completed'

    document = job.arguments.first

    case document.documentable_type
      when 'Protocol'
        protocol = Protocol.find(job.arguments.last[:documentable_id])
        protocol.document_counter_updated = true
        protocol.update_attributes(unaccessed_documents_count: (protocol.unaccessed_documents_count + 1))
      when 'Identity'
        find_identity(job).update_counter(:unaccessed_documents, 1)
    end
  end

  private

  def find_identity(job)
    @identity ||= Identity.find job.arguments.last[:identity_id]
  end

  def find_or_create_document_root_path
    unless Dir.exists? ENV.fetch('DOCUMENTS_FOLDER')
      Dir.mkdir ENV.fetch('DOCUMENTS_FOLDER')
    end
  end
end
