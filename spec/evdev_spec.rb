describe Evdev do
  subject(:klass) { described_class }
  subject(:instance) { klass.new(:file_path) }

  let(:file) { instance_double(File, fileno: :fd) }
  let(:device_ptr) { instance_double(FFI::MemoryPointer, read_pointer: :input_device) }
  before { allow(File).to receive(:open).with(:file_path).and_return(file) }
  before { allow(FFI::MemoryPointer).to receive(:new).with(:pointer).and_return(device_ptr) }
  before { allow(Libevdev).to receive(:free).with(:input_device) }
  before { allow(Libevdev).to receive(:new_from_fd).with(:fd, device_ptr) }

  it 'has a version number' do
    expect(Evdev::VERSION).not_to be nil
  end

  describe "Freeing the device after an instance is gc'ed" do
    subject { GC.start }
    before { @instance = klass.new(:file_path) }
    before { expect(Libevdev).to receive(:free).with(:input_device) }
    before { @instance = nil }
    it { is_expected.not_to raise_error }
  end

  describe ".all: Gets all event devices" do
    subject { klass.all }

    before { allow(Dir).to receive(:[]).with('/dev/input/event*').
        and_return(%w(/dev/input/event0 /dev/input/event1)) }
    before { allow(klass).to receive(:new).with('/dev/input/event0').and_return(:device0) }
    before { allow(klass).to receive(:new).with('/dev/input/event1').and_return(:device1) }

    it { is_expected.to eq %i(device0 device1) }
  end

  describe "#file: Gets its file handle" do
    subject { instance.file }
    it { is_expected.to eq file }
  end

  describe "#event_channel: Alias for #file" do
    subject { instance.event_channel }
    it { is_expected.to eq file }
  end

  describe "#name: Gets its name" do
    subject { instance.name }
    before { allow(Libevdev).to receive(:get_name).with(:input_device).and_return(:name) }
    it { is_expected.to be :name }
  end

  describe "#phys: Gets its physical location" do
    subject { instance.phys }
    before { allow(Libevdev).to receive(:get_phys).with(:input_device).and_return(:phys) }
    it { is_expected.to be :phys }
  end

  describe "#uniq: Gets its unique identifier" do
    subject { instance.uniq }
    before { allow(Libevdev).to receive(:get_uniq).with(:input_device).and_return(:uniq) }
    it { is_expected.to be :uniq }
  end

  describe "#vendor_id: Gets its vendor id" do
    subject { instance.vendor_id }
    before { allow(Libevdev).to receive(:get_id_vendor).with(:input_device).and_return(:vendor_id) }
    it { is_expected.to be :vendor_id }
  end

  describe "#product_id: Gets its product id" do
    subject { instance.product_id }
    before { allow(Libevdev).to receive(:get_id_product).with(:input_device).and_return(:product_id) }
    it { is_expected.to be :product_id }
  end

  describe "#bustype: Gets its bus type" do
    subject { instance.bustype }
    before { allow(Libevdev).to receive(:get_id_bustype).with(:input_device).and_return(:bustype) }
    it { is_expected.to be :bustype }
  end

  describe "#version: Gets its firmware version" do
    subject { instance.version }
    before { allow(Libevdev).to receive(:get_id_version).with(:input_device).and_return(:version) }
    it { is_expected.to be :version }
  end

  describe "#driver_version: Gets its driver's version" do
    subject { instance.driver_version }
    before { allow(Libevdev).to receive(:get_driver_version).with(:input_device).and_return(:driver_version) }
    it { is_expected.to be :driver_version }
  end

  describe "#has_property?: Checks if it has the given property" do
    subject { instance.has_property?(:property) }

    before { allow(klass::Converter).to receive(:property_to_int).with(:property).
        and_return(:property_int) }

    context "when it has the property" do
      before { allow(Libevdev).to receive(:has_property).with(:input_device, :property_int).and_return(1) }
      it { is_expected.to be true }
    end

    context "when it does not have the property" do
      before { allow(Libevdev).to receive(:has_property).with(:input_device, :property_int).and_return(0) }
      it { is_expected.to be false }
    end
  end

  describe "#abs_axis: Gets the information object of the given absolute axis" do
    subject { instance.abs_axis(:ABS_AXIS) }
    before { allow(klass::Converter).to receive(:code_to_int).with(:ABS_AXIS).
        and_return(:code_int) }
    before { allow(klass::AbsAxis).to receive(:new).with(:input_device, :code_int).and_return(:abs_axis) }
    it { is_expected.to be :abs_axis }
  end

  describe "#grab: Grabs the device" do
    subject { instance.grab }
    before { expect(Libevdev).to receive(:grab).with(:input_device, Libevdev::GRAB) }

    context "when the grab is successful" do
      before { allow(Libevdev).to receive(:grab).and_return(0) }
      it { is_expected.to be true }
    end

    context "when the grab failed" do
      before { allow(Libevdev).to receive(:grab).and_return(-1) }
      it { is_expected.to be false }
    end
  end

  describe "#ungrab: Ungrabs the device" do
    subject { instance.ungrab }
    before { expect(Libevdev).to receive(:grab).with(:input_device, Libevdev::UNGRAB) }

    context "when the ungrab is successful" do
      before { allow(Libevdev).to receive(:grab).and_return(0) }
      it { is_expected.to be true }
    end

    context "when the ungrab failed" do
      before { allow(Libevdev).to receive(:grab).and_return(-1) }
      it { is_expected.to be false }
    end
  end

  describe "#supports_event?: Checks if it supports the given event" do
    subject { instance.supports_event?(:TYPE_CODE) }

    before { allow(klass::Converter).to receive(:code_to_type).with(:TYPE_CODE).and_return(:EV_TYPE) }
    before { allow(klass::Converter).to receive(:type_to_int).with(:EV_TYPE).and_return(:type_int) }
    before { allow(klass::Converter).to receive(:code_to_int).with(:TYPE_CODE).and_return(:code_int) }

    context "when it does not support the event's type" do
      before { allow(Libevdev).to receive(:has_event_type).with(:input_device, :type_int).and_return(0) }
      before { allow(Libevdev).to receive(:has_event_code).with(:input_device, :type_int, :code_int).
          and_return(1) }
      it { is_expected.to be false }
    end

    context "when it does not support the event's code" do
      before { allow(Libevdev).to receive(:has_event_type).with(:input_device, :type_int).and_return(1) }
      before { allow(Libevdev).to receive(:has_event_code).with(:input_device, :type_int, :code_int).
          and_return(0) }
      it { is_expected.to be false }
    end

    context "when it does support the event" do
      before { allow(Libevdev).to receive(:has_event_type).with(:input_device, :type_int).and_return(1) }
      before { allow(Libevdev).to receive(:has_event_code).with(:input_device, :type_int, :code_int).
          and_return(1) }
      it { is_expected.to be true }
    end
  end

  describe "#handle_event: Reads the next event in the given mode and processes it" do
    subject { instance.handle_event }

    let(:event) { instance_double(LinuxInput::InputEvent, pointer: :event_ptr) }
    before { allow(event).to receive(:[]).with(:type).and_return(:event_type) }
    before { allow(event).to receive(:[]).with(:code).and_return(:event_code) }
    before { allow(event).to receive(:[]).with(:value).and_return(:event_value) }
    before { allow(klass::Converter).to receive(:int_to_name).with(:event_type, :event_code).
        and_return(:event_name) }
    before { allow(LinuxInput::InputEvent).to receive(:new).and_return(event) }

    before { allow(Libevdev).to receive(:next_event) }
    before { allow(instance).to receive(:trigger) }

    context "when a read mode is given implicitly" do
      before { expect(Libevdev).to receive(:next_event).with(:input_device,
        Libevdev::READ_FLAG_BLOCKING, :event_ptr) }

      before { expect(instance).to receive(:trigger).with(:event_name, :event_value, :event_name) }
      it { is_expected.not_to raise_error }
    end

    context "when a read mode is given explicitly" do
      subject { instance.handle_event(:normal) }
      before { expect(Libevdev).to receive(:next_event).with(:input_device,
        Libevdev::READ_FLAG_NORMAL, :event_ptr) }

      before { expect(instance).to receive(:trigger).with(:event_name, :event_value, :event_name) }
      it { is_expected.not_to raise_error }
    end

    context "when no events are pending" do
      before { expect(Libevdev).to receive(:next_event).and_raise Errno::EAGAIN }

      before { expect(instance).not_to receive(:trigger) }
      it { is_expected.to raise_error(Evdev::AwaitEvent) }
    end
  end

  describe "#event_pending?: Checks if it has pending events" do
    subject { instance.events_pending? }

    context "when it has pending events" do
      before { allow(Libevdev).to receive(:has_event_pending).with(:input_device).and_return(1) }
      it { is_expected.to be true }
    end

    context "when it does not have pending events" do
      before { allow(Libevdev).to receive(:has_event_pending).with(:input_device).and_return(0) }
      it { is_expected.to be false }
    end
  end

  describe "event_value: Gets the value of a the last event of the given type" do
    subject { instance.event_value(:TYPE_CODE) }

    before { allow(instance).to receive(:supports_event?).with(:TYPE_CODE).and_return(true) }
    before { allow(klass::Converter).to receive(:code_to_type).with(:TYPE_CODE).and_return(:EV_TYPE) }
    before { allow(klass::Converter).to receive(:type_to_int).with(:EV_TYPE).and_return(:type_int) }
    before { allow(klass::Converter).to receive(:code_to_int).with(:TYPE_CODE).and_return(:code_int) }

    before { allow(Libevdev).to receive(:get_event_value).with(:input_device, :type_int, :code_int).
        and_return(:event_value) }
    it { is_expected.to be :event_value }

    context "when it does not support the event" do
      before { allow(instance).to receive(:supports_event?).with(:TYPE_CODE).and_return(false) }
      it { is_expected.to be nil }
    end
  end
end
