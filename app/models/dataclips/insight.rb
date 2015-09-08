module Dataclips
  class Insight < ActiveRecord::Base
    validates :clip_id, presence: true
    validates :checksum, presence: true, uniqueness: true

    before_validation :calculate_checksum

    def to_param
      hash_id
    end

    def self.get(clip_id, params = nil)
      find_by(clip_id: clip_id)
    end

    def self.get!(clip_id, params = nil, excludes = [])
      Dataclips::Insight.where(clip_id: clip_id).detect do |di|
        di.params == params
      end || Dataclips::Insight.create!(clip_id: clip_id, name: "#{params.to_s.parameterize}", params: params, excludes: excludes || [])
    end

    def self.find_by_hash_id(hash_id)
      find_by(id: Dataclips.hashids.decode(hash_id))
    end

    def hash_id
      return unless persisted?
      Dataclips.hashids.encode(id)
    end

    def time_zone
      read_attribute(:time_zone) || Rails.configuration.time_zone
    end

    def calculate_checksum
      self.checksum = Digest::MD5.hexdigest Marshal.dump(slice(:clip_id, :params))
    end
  end
end
