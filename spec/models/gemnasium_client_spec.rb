# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GemnasiumClient do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates an GemnasiumClient instance' do
      expect(client).to be_an described_class
    end
  end

  describe '#all_projects_and_counts' do
    before do
      projects = file_fixture('gemnasium_client_list_projects').read
      alerts_hw = file_fixture('gemnasium_client_list_alerts_hello_world').read
      alerts_hwc = file_fixture('gemnasium_client_list_alerts_hello_world_clean').read
      alerts_hwt = file_fixture('gemnasium_client_list_alerts_hello_world_test').read
      stub_request(:any, 'https://api.gemnasium.com/v1/projects').to_return(status: 200, body: projects)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world/alerts').to_return(status: 200, body: alerts_hw)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world-clean/alerts').to_return(status: 200, body: alerts_hwc)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world-test/alerts').to_return(status: 200, body: alerts_hwt)
    end

    it 'returns a hash' do
      expect(client.all_projects_and_counts).to be_kind_of Hash
    end

    it 'returns an array for each key' do
      expect(client.all_projects_and_counts.first).to be_kind_of Array
    end

    it 'returns accurate project name and count' do
      sorted = client.all_projects_and_counts.sort_by { |e| e[0] }
      expect(sorted.first).to eq ['sul-dlss/hello-world', 2]
    end
  end

  describe '#all_dependencies' do
    before do
      projects = file_fixture('gemnasium_client_list_projects').read
      deps_hw = file_fixture('gemnasium_client_list_dependencies_hello_world').read
      deps_hwc = file_fixture('gemnasium_client_list_dependencies_hello_world_clean').read
      stub_request(:any, 'https://api.gemnasium.com/v1/projects').to_return(status: 200, body: projects)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world/dependencies').to_return(status: 200, body: deps_hw)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world-clean/dependencies').to_return(status: 200, body: deps_hwc)
      stub_request(:any, 'https://api.gemnasium.com/v1/projects/sul-dlss/hello-world-test/dependencies').to_return(status: 200, body: deps_hwc)
    end

    it 'returns a hash' do
      expect(client.all_dependencies).to be_kind_of Hash
    end

    it 'returns an array for each key' do
      expect(client.all_dependencies.first).to be_kind_of Array
    end

    it 'returns accurate project name' do
      sorted = client.all_dependencies.sort_by { |e| e[0] }
      project, _deps = sorted.first
      expect(project).to eq 'sul-dlss/hello-world'
    end

    it 'returns accurate project dependencies' do
      sorted = client.all_dependencies.sort_by { |e| e[0] }
      _project, deps = sorted.first
      expect(deps.count).to eq 2
    end
  end
end
