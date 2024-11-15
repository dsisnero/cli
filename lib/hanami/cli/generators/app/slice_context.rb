# frozen_string_literal: true

require_relative "../context"
require_relative "../constants"

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.0.0
        # @api private
        class SliceContext < Generators::Context
          # @since 2.0.0
          # @api private
          def initialize(inflector, app, slice, url, **options)
            @slice = slice
            @url = url
            super(inflector, app, **options)
          end

          # @since 2.0.0
          # @api private
          def camelized_slice_name
            inflector.camelize(slice)
          end

          # @since 2.0.0
          # @api private
          def underscored_slice_name
            inflector.underscore(slice)
          end

          # @since 2.1.0
          # @api private
          def humanized_slice_name
            inflector.humanize(slice)
          end

          # @since 2.1.0
          # @api private
          def stylesheet_erb_tag
            %(<%= stylesheet_tag "app" %>)
          end

          # @since 2.1.0
          # @api private
          def javascript_erb_tag
            %(<%= javascript_tag "app" %>)
          end

          # @since 2.2.0
          # @api private
          def generate_db?
            !options.fetch(:skip_db, false)
          end

          # @since 2.2.0
          # @api private
          def generate_route?
            !options.fetch(:skip_route, false)
          end

          private

          attr_reader :slice

          attr_reader :url
        end
      end
    end
  end
end
