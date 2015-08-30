# Evdev

A ruby wrapper around [Libevdev](https://github.com/christopheraue/ruby-libevdev)
for a nice and easy access to linux's event devices like keyboards and mice.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'evdev'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evdev

## Usage

Let's have a look at my keyboard:

### Initializing a device

```ruby
require 'evdev'
keyboard = Evdev.new('/dev/input/event0')
```

### Querying the device

```ruby
keyboard.name                       # => "Logitech USB Receiver"
keyboard.phys                       # => "usb-0000:00:1d.2-1/input0"
keyboard.uniq                       # => ""
keyboard.vendor_id                  # => 1133
keyboard.product_id                 # => 50473
keyboard.bustype                    # => :USB
keyboard.version                    # => 273
keyboard.driver_version             # => 65537
keyboard.has_property? :pointer     # => false
```

### Grabbing a device

```ruby
keyboard.grab                       # => true if successful, else false
keyboard.ungrab                     # => true if successful, else false
```

### Event handling

Evdev lumps event type and code together. You just need to give it the name of
the code and it derives the implied type from it internally.

```ruby
keyboard.supports_event? :KEY_A     # => true
keyboard.supports_event? :ABS_X     # => false

key_a_handler = keyboard.on(:KEY_A) do |value|
    puts "key 'a' #{%w(up down repeat)[value]}"
end

loop do
    Kernel.select([keyboard.event_channel])
    keyboard.handle_event
    # => puts "key 'a' down" and "key 'a' up" on a single KEY_A stroke
end
```

Removing the handler:

```ruby
keyboard.off(:KEY_A, key_a_handler)
```

Evdev includes the [CallbacksAttachable](https://github.com/christopheraue/ruby-callbacks_attachable)
mixin to attach and detach callbacks. Have a look at its API in its own documentation.