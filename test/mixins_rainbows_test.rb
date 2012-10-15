# -*- encoding: binary -*-
require 'rainbows'
require File.expand_path('../test_helper', __FILE__)

Rainbows.forked = true

require 'cool.io'

module Unicorn::HttpResponse
  def write_response(socket, status, headers, body)
    (@data ||= [ ]).push(data)
  end
end

class MixinsRainbowsTest < Test::Unit::TestCase
  def test_mixin
    assert(Rainbows::ProcessClient.include?(Palmade::SocketIoRack::Mixins::Rainbows::WebsocketConnection), "Rainbows connection mixin not included")
  end

  def test_websocket_upgrade
    ws_handler = MockWebSocketHandler.new

    sec_key1 = generate_key
    sec_key2 = generate_key
    sec_key3 = generate_key3
    expected_digest = security_digest(sec_key1, sec_key2, sec_key3)
    assert(expected_digest.length == 16, "security digest generated is wrong")

    env = {
      "HTTP_SEC_WEBSOCKET_KEY1" => sec_key1,
      "HTTP_SEC_WEBSOCKET_KEY2" => sec_key2,
      "HTTP_ORIGIN" => "localhost",
      "Connection" => "Upgrade",
      "Upgrade" => "Connection"
    }

    result = [
              101,
              {
                "Connection" => "Upgrade",
                "Upgrade" => "WebSocket",
                "ws_handler" => ws_handler
              },
              ""
             ]

    conn = Rainbows::Client.new(1)
    conn.post_init
    conn.request.env.merge!(env)
    conn.request.body.write(sec_key3)
    conn.request.body.rewind

    conn.post_process(result)

    assert(result.last.length == 16, "expected security digest is of different length")
    assert(result.last == expected_digest, "expected security digest is wrong")

    assert(conn.websocket_connected?, "websocket not connected")
    assert(conn.websocket?, "websocket connection not properly set")
  end

  def security_digest(key1, key2, key3)
    bytes1 = websocket_key_to_bytes(key1)
    bytes2 = websocket_key_to_bytes(key2)
    Digest::MD5.digest(bytes1 + bytes2 + key3)
  end

  def websocket_key_to_bytes(key)
    num = key.gsub(/[^\d]/n, "").to_i() / key.scan(/ /).size
    [num].pack("N")
  end

  def generate_key3
    [rand(0x100000000)].pack("N") + [rand(0x100000000)].pack("N")
  end

  NOISE_CHARS = ("\x21".."\x2f").to_a() + ("\x3a".."\x7e").to_a()
  def generate_key
    spaces = 1 + rand(12)
    max = 0xffffffff / spaces
    number = rand(max + 1)
    key = (number * spaces).to_s()
    (1 + rand(12)).times() do
      char = NOISE_CHARS[rand(NOISE_CHARS.size)]
      pos = rand(key.size + 1)
      key[pos...pos] = char
    end
    spaces.times() do
      pos = 1 + rand(key.size - 1)
      key[pos...pos] = " "
    end
    key
  end
end
