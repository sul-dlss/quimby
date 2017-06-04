# frozen_string_literal: true

class RepoData
  attr_reader :client, :org

  def initialize(org)
    @client = GithubClient.new(org)
    @org = org
  end

  def load_basic_repo_data
    client.all_repos.map do |r|
      Repository.find_or_create_by(name: r.name, organization: org) do |repo|
        repo.url = r.html_url
        repo.language = r.language
      end
    end
  end

  def load_capistrano_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_exists? repo.name, 'Capfile'
      repo.update(has_capistrano: response)
    end
  end

  def load_rspec_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_exists? repo.name, '.rspec'
      repo.update(has_rspec: response)
    end
  end

  def load_travis_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_exists? repo.name, '.travis.yml'
      repo.update(has_travis: response)
    end
  end

  def load_okcomputer_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_exists? repo.name, 'config/initializers/okcomputer.rb'
      repo.update(has_okcomputer: response)
    end
  end

  def load_is_it_working_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_exists? repo.name, 'config/initializers/is_it_working.rb'
      repo.update(has_is_it_working: response)
    end
  end

  def load_honeybadger_data
    Repository.where(organization: org).find_each do |repo|
      response = client.repo_file_contains? repo.name, 'Gemfile', 'honeybadger'
      repo.update(has_honeybadger: response)
    end
  end
end
