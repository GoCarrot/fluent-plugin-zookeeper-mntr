# frozen_string_literal: true

# Copyright 2022 Teak.io, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
        timer_execute(:in_zookeeper_mntr_runner, 0, repeat: false, &method(:run))
        timer_execute(:in_zookeeper_mntr_runner, @interval, &method(:run))
      end

    private

      def run
        socket_create_tcp(@host, @port) do |socket|
          socket.write('mntr')
          data = socket.read
          message =
            if data.start_with?('This ZooKeeper')
              { 'error' => data }
            else
              Hash[data.split("\n").map! { |row| row.split("\t") }]
            end

          message.transform_values! do |value|
            if value =~ /\A\-?[0-9]+\z/
              value.to_i
            else
              value
            end
          end

          router.emit(@tag, Fluent::EventTime.now, message)
        end
      rescue StandardError => exc
        router.emit(@tag, Fluent::EventTime.now, { 'error' => exc.message })
      end
    end
  end
end
