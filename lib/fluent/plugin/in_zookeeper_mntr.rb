# frozen_string_literal: true

require 'fluent/plugin/input'

module Fluent
  module Plugin
    class ZookeeperMntrInput < Input
      Fluent::Plugin.register_input('zookeeper_mntr', self)

      helpers :socket, :timer

      config_param :tag, :string
      config_param :port, :integer, default: 2181
      config_param :host, :string, default: 'localhost'
      config_param :interval, :time, default: 60

      def start
        super
        @finished = false
        timer_execute(:in_zookeeper_mntr_runner, @interval, &method(:run))
      end

      def shutdown
        @finished = true
        super
      end

    private

      def run
        socket_create_tcp(@host, @port) do |socket|
          socket.write('mntr')
          data = socket.read
          message = Hash[
            data.split("\n").map { |row| row.split("\t") }
          ]
          router.emit(@tag, Fluent::EventTime.now, message)
        end
      end
    end
  end
end
