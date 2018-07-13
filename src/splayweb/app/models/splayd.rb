class Splayd < ApplicationRecord
  belongs_to :user
  has_many :splayd_selections
  has_many :jobs, :through => :splayd_selections
end