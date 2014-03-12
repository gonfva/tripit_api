#
# Copyright 2008-2012 Concur Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
module TripIt
  class TravelObj
    def self.new(element)
        children = Hash.new do |h, k|
            h[k] = []
        end
        elements = {}
        element.elements.each do |e|
            if /^[A-Z]/.match(e.name)
                name = e.name.intern
                klass = if TripIt.const_defined?(name,false)
                    TripIt.const_get(name,false)
                else
                    TripIt.const_set(name, Class.new(TravelObj))
                end
                children[klass] << klass.new(e)
            else
                elements[e.name] = \
                if e.name[-4..-1] == 'date' or e.name[-4..-1] == 'time'
                    ::DateTime.parse(e.text)
                else
                    e.text
                end
            end
        end
        if self == TravelObj
            # Root. There will be just one Response object.
            children.values.flatten[0]
        else
            super(children, elements)
        end
    end

    def initialize(children, elements)
        @children, @elements = children, elements
    end

    def to_xml(container = REXML::Document.new)
        element = container.add_element(self.class.name.split('::')[-1])
        @elements.each_pair do |k, v|
            if not v.nil?
                element.add_element(k).text = if v.kind_of? ::DateTime
                    if k[-4..-1] == 'time'
                        v.strftime('%H:%M:%S')
                    else
                        v.strftime('%Y-%m-%d')
                    end
                else
                    v
                end
            end
        end
        self[].each do |child|
            child.to_xml(element)
        end
        container
    end

    def elements
        @elements.keys
    end

    def children
        @children.keys
    end

    def [](name = nil)
        if name.nil?
            @children.values.flatten
        elsif name.kind_of? Class
            @children[name]
        else
            @elements[name]
        end
    end

    def []=(name, value)
        @elements[name] = value
    end

    def add_child(obj)
        @children[obj.class] << obj
    end
  end
end

