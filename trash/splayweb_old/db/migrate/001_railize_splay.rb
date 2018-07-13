## Splayweb ### v1.1 ###
## Copyright 2006-2011
## http://www.splay-project.org
## 
## 
## 
## This file is part of Splayd.
## 
## Splayd is free software: you can redistribute it and/or modify 
## it under the terms of the GNU General Public License as published 
## by the Free Software Foundation, either version 3 of the License, 
## or (at your option) any later version.
## 
## Splayd is distributed in the hope that it will be useful,but 
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
## See the GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Splayd. If not, see <http://www.gnu.org/licenses/>.

class RailizeSplay < ActiveRecord::Migration
  def self.up
		add_column :splayds, :user_id, :integer, :default => 1
		add_column :splayds, :created_at, :datetime
		add_column :jobs, :user_id, :integer, :default => 1
		add_column :jobs, :created_at, :datetime
  end

  def self.down
		remove_column :splayds, :user_id
		remove_column :splayds, :created_at
		remove_column :jobs, :user_id
		remove_column :jobs, :created_at
  end
end
