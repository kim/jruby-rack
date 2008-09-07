#--
# Copyright 2007-2008 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

#--
# Stubbed out Rails classes for testing
#++

module ActionController
  class CgiRequest
    DEFAULT_SESSION_OPTIONS = {}
  end

  class Base
    class << self
      attr_accessor :page_cache_directory, :relative_url_root
      def session_store
        ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:database_manager]
      end
      def session_store=(store)
        # Faking camelize so we don't have to have active_support installed
        camelized_store = store.to_s.gsub(/(?:^|_)([a-z])/) {|match| match[-1,1].upcase}
        ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:database_manager] =
          store.is_a?(Symbol) ? CGI::Session.const_get(store == :drb_store ? "DRbStore" : camelized_store) : store
      end
    end
  end
end

module ActionView
  module Helpers
    module AssetTagHelper
      ASSETS_DIR = "public"
      JAVASCRIPTS_DIR = "#{ASSETS_DIR}/javascripts"
      STYLESHEETS_DIR = "#{ASSETS_DIR}/stylesheets"
    end
  end
end
