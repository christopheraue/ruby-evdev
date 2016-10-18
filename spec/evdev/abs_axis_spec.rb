describe Evdev::AbsAxis do
  subject(:klass) { described_class }
  subject(:instance) { klass.new(:input_device, :code) }

  describe "#maximum: Gets its maximum value" do
    subject { instance.maximum }
    before { allow(Libevdev).to receive(:get_abs_maximum).with(:input_device, :code).and_return(:maximum) }
    it { is_expected.to be :maximum }
  end

  describe "#minimum: Gets its minimum value" do
    subject { instance.minimum }
    before { allow(Libevdev).to receive(:get_abs_minimum).with(:input_device, :code).and_return(:minimum) }
    it { is_expected.to be :minimum }
  end

  describe "#fuzz: Gets its fuzz value" do
    subject { instance.fuzz }
    before { allow(Libevdev).to receive(:get_abs_fuzz).with(:input_device, :code).and_return(:fuzz) }
    it { is_expected.to be :fuzz }
  end

  describe "#flat: Gets its flat value" do
    subject { instance.flat }
    before { allow(Libevdev).to receive(:get_abs_flat).with(:input_device, :code).and_return(:flat) }
    it { is_expected.to be :flat }
  end

  describe "#resolution: Gets its resolution" do
    subject { instance.resolution }
    before { allow(Libevdev).to receive(:get_abs_resolution).with(:input_device, :code).and_return(:resolution) }
    it { is_expected.to be :resolution }
  end
end