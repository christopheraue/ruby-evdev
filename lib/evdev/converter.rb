class Evdev
  module Converter; end
  class << Converter
    def code_to_type(code)
      :"EV_#{code.to_s.split('_').first}"
    end

    def property_to_int(property)
      LinuxInput.const_get(:"INPUT_PROP_#{property.upcase}")
    end

    def type_to_int(type)
      LinuxInput.const_get(type.upcase)
    end

    def code_to_int(code)
      LinuxInput.const_get(code.upcase)
    end

    def int_to_name(type_int, code_int)
      @event_names ||= {}
      @event_names[type_int] ||= consts_starting_with("#{int_to_type(type_int)}_")
      @event_names[type_int][code_int]
    end

    def int_to_type(int)
      @event_types ||= consts_starting_with('EV_')
      @event_types[int][3..-1]
    end

    private

    def consts_starting_with(prefix)
      LinuxInput.constants(false).map do |const|
        [LinuxInput.const_get(const), const] if const.to_s.starts_with? prefix
      end.compact.to_h
    end
  end
end