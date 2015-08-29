class Evdev
  class AbsAxis
    def initialize(device, code)
      @device = device
      @code = code
    end

    def maximum
      Libevdev.get_abs_maximum(@device, @code)
    end

    def minimum
      Libevdev.get_abs_minimum(@device, @code)
    end

    def fuzz
      Libevdev.get_abs_fuzz(@device, @code)
    end

    def flat
      Libevdev.get_abs_flat(@device, @code)
    end

    def resolution
      Libevdev.get_abs_resolution(@device, @code)
    end
  end
end