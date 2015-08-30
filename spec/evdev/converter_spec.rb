describe Evdev::Converter do
  subject(:instance) { described_class.clone }

  describe ".code_to_type: Converts an event code into a type" do
    subject { instance.code_to_type(:TYPE_CODE) }
    it { is_expected.to be :EV_TYPE }
  end

  describe ".property_to_int: Converts a property name into its int representation" do
    subject { instance.property_to_int(:pointer) }
    it { is_expected.to be LinuxInput::INPUT_PROP_POINTER }
  end

  describe ".type_to_int: Converts an event type into its int representation" do
    subject { instance.type_to_int(:ev_key) }
    it { is_expected.to be LinuxInput::EV_KEY }
  end

  describe ".code_to_int: Converts an event code into its int representation" do
    subject { instance.code_to_int(:key_a) }
    it { is_expected.to be LinuxInput::KEY_A }
  end

  describe "#int_to_name: Converts event type and code ints into a name" do
    subject { instance.int_to_name(LinuxInput::EV_KEY, LinuxInput::KEY_A) }
    it { is_expected.to be :KEY_A }
  end
end