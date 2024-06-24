# frozen_string_literal: true

require "ripper"

module Hanami
  module CLI
    class RubyFileGenerator
      class GeneratedUnparseableCodeError < Error
        def initialize(source_code)
          super(
            <<~ERROR_MESSAGE
              Sorry, the code we generated is not valid Ruby.

              Here's what we got:

              #{source_code}

              Please fix the errors and try again.
            ERROR_MESSAGE
          )
        end
      end

      INDENT = "  "

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        class_name: nil,
        parent_class: nil,
        modules: [],
        header: [],
        body: []
      )
        @class_name = class_name
        @parent_class = parent_class
        @modules = modules
        @header = header.any? && (header + [""]) || header
        @body = body
      end
      # rubocop:enable Metrics/ParameterLists

      def self.class(class_name, **)
        new(class_name: class_name, **).to_s
      end

      def self.module(*names, **)
        module_names = if names.first.is_a?(Array)
                        names.first
                      else
                        names
                      end

        new(modules: module_names, class_name: nil, parent_class: nil, **).to_s
      end

      def to_s
        definition = lines(modules).map { |line| "#{line}\n" }.join

        source_code = [header, definition].flatten.join("\n")

        ensure_parseable!(source_code)
      end


      private

      attr_reader(
        :class_name,
        :parent_class,
        :modules,
        :header,
        :body
      )

      def lines(remaining_modules)
        this_module, *rest_modules = remaining_modules
        if this_module
          with_module_lines(this_module, lines(rest_modules))
        elsif class_name
          class_lines
        else
          body
        end
      end

      def with_module_lines(module_name, contents_lines)
        [
          "module #{module_name}",
          *contents_lines.map { |line| indent(line) },
          "end"
        ]
      end


      def class_lines
        if class_name
          [
            class_definition,
            *body.map { |line| indent(line) },
            "end"
          ].compact
        else
          []
        end
      end

      def class_definition
        if parent_class
          "class #{class_name} < #{parent_class}"
        else
          "class #{class_name}"
        end
      end

      def indent(line)
        if line.strip.empty?
          ""
        else
          INDENT + line
        end
      end

      def ensure_parseable!(source_code)
        parse_result = Ripper.sexp(source_code)

        if parse_result
          source_code
        else
          raise GeneratedUnparseableCodeError.new(source_code)
        end
      end
    end
  end
end
