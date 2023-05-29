# frozen_string_literal: true

require 'pathname'

module ChatwootApp
  def self.root
    Pathname.new(File.expand_path('..', __dir__))
  end

  def self.max_limit
    100_000
  end

  def self.enterprise?
    return if ENV.fetch('DISABLE_ENTERPRISE', false)

    @enterprise ||= root.join('enterprise').exist?
  end

  def self.custom?
    @custom ||= root.join('custom').exist?
  end

  def self.extensions
    enterprise? ? enterprise_extensions : community_extensions
  end

  def self.enterprise_extensions
    custom? ? %w[enterprise custom] : %w[enterprise]
  end

  def self.community_extensions
    custom? ? %w[custom] : %w[]
  end
end
