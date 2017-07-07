require "callbacks_attachable"
require "libevdev"

require_relative "evdev/version"
require_relative "evdev/converter"
require_relative "evdev/abs_axis"

class Evdev
  include CallbacksAttachable

  class << self
    def finalize(device)
      proc { Libevdev.free(device) }
    end

    def all(file_paths = '/dev/input/event*')
      Dir[file_paths].map{ |file_path| new(file_path) }
    end
  end

  def initialize(file_path)
    @file = File.open(file_path)
    device_ptr = FFI::MemoryPointer.new :pointer
    Libevdev.new_from_fd(@file.fileno, device_ptr)
    @device = device_ptr.read_pointer

    ObjectSpace.define_finalizer(self, self.class.finalize(@device))
  end

  attr_reader :file
  alias_method :event_channel, :file

  def name
    Libevdev.get_name(@device)
  end

  def phys
    Libevdev.get_phys(@device)
  end

  def uniq
    Libevdev.get_uniq(@device)
  end

  def vendor_id
    Libevdev.get_id_vendor(@device)
  end

  def product_id
    Libevdev.get_id_product(@device)
  end

  def bustype
    Libevdev.get_id_bustype(@device)
  end

  def version
    Libevdev.get_id_version(@device)
  end

  def driver_version
    Libevdev.get_driver_version(@device)
  end

  def has_property?(property)
    1 == Libevdev.has_property(@device, Converter.property_to_int(property))
  end

  def abs_axis(code)
    AbsAxis.new(@device, Converter.code_to_int(code))
  end

  def grab
    0 == Libevdev.grab(@device, Libevdev::GRAB)
  end

  def ungrab
    0 == Libevdev.grab(@device, Libevdev::UNGRAB)
  end

  def supports_event?(event)
    type = Converter.code_to_type(event)
    handles_event_type?(type) and handles_event_code?(type, event)
  end

  def handle_event(mode = :blocking)
    event = LinuxInput::InputEvent.new
    Libevdev.next_event(@device, Libevdev.const_get(:"READ_FLAG_#{mode.upcase}"), event.pointer)
    trigger(Converter.int_to_name(event[:type], event[:code]), event[:value])
  end

  def events_pending?
    1 == Libevdev.has_event_pending(@device)
  end

  def event_value(event)
    return unless supports_event?(event)
    type = Converter.code_to_type(event)
    Libevdev.get_event_value(@device, Converter.type_to_int(type), Converter.code_to_int(event))
  end

  private

  def handles_event_type?(type)
    1 == Libevdev.has_event_type(@device, Converter.type_to_int(type))
  end

  def handles_event_code?(type, code)
    1 == Libevdev.has_event_code(@device, Converter.type_to_int(type), Converter.code_to_int(code))
  end
end
