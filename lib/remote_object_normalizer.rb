# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

class RemoteObjectNormalizer

  def initialize(local_object_class, remote_object_attributes)
    @local_object_class       = local_object_class
    @remote_object_attributes = remote_object_attributes
  end

  def normalize!
    filter(@remote_object_attributes, @local_object_class)
  end

  private

  def filter(remote_object_attributes, klass)
    attributes                  = Hash.new
    local_object_attribute_keys = class_attribute_filter(klass)

    remote_object_attributes.
      reject { |key, value| !local_object_attribute_keys.include?(key) }.
      each { |key, value| attributes.merge! Hash[key, value] }

    attributes
  end

  def class_attribute_filter(klass)
    klazz       = klass.classify.constantize
    instance    = klazz.new
    attributes  = instance.attributes.keys

    attributes.delete_if { |attribute| universal_attribute_filter.include?(attribute) }
  end

  def universal_attribute_filter
    ['id', 'created_at', 'updated_at', 'deleted_at'].freeze
  end
end
