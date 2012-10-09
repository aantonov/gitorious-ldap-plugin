# PMO Client for Gitorious
#
# Install rest-client and json gems first
# sudo gem install rest-client json
#

if RUBY_VERSION < '1.9'
  require 'rubygems'
end

require 'rest_client'
require 'json'

class PMOClient

  #
  # Creates new instance of PMOClient class
  #
  # base_url: PMO url
  # username: username to login
  # password: username's password
  #
  def initialize(base_url, username, password)
    @base_url = base_url
    @username = username
    @password = password
  end


  #
  # Executes GET request to the specified url
  #
  # url: subURL for executing request
  #
  def request_execute(url)
    RestClient::Request.new(:method => :get, :url => URI.encode(@base_url + url),
                                       :user => @username, :password => @password,
                                       :headers => { :accept => :json, :content_type => :json }).execute
  end


  #
  # Gets information about company accounts
  #
  # Return format:
  # {
  #   "AccountName1" => ["Project1", "Project2"],
  #   "AccountName2" => ["Project1"],
  #   ...
  # }
  #
  def get_accounts()
    response = request_execute("/service/accounts/")

    accounts = Hash.new

    for account in JSON.parse(response)
      projects = []
      for project in account["projects"]
        projects << project["name"]
      end

      accounts[account["name"]] = projects
    end
    accounts
  end


  #
  # Gets information about assignment for specified project
  #
  # project_name: name of the project
  #
  # Return format:
  #  {
  #    "userid1" => {
  #      "role" => "ROLE",
  #      "employee" => {
  #          ....
  #      }
  #    },
  #    "userid2" => {
  #      "role" => "ROLE",
  #      "employee" => {
  #          ....
  #      }
  #    }
  #  }
  #
  # Roles:
  # TL - team lead
  # PM - project manager
  # CA - client architect
  # DM - development manager
  # SE - staff/software engineer
  # QE - QA engineer
  # DE - deployment engineer
  #
  # Example:
  # {
  #   "iivanov" => {
  #     "role" => "TL",
  #     "employee" => {
  #        "username" => "iivanov",
  #        "deleted" => false,
  #        "legalPerson" => {
  #          "name" => "Company Name",
  #          "id" => 2,
  #          "code" => "CN",
  #        },
  #        "grade" => {
  #           "track" => "A",
  #           "level" => 1
  #        },
  #        "hiringDate" => "03/01/2012",
  #        "internalPhone" => null,
  #        "department" => null,
  #        "firstName" => "Ivan",
  #        "legalFirstName" => null,
  #        "legalFamilyName" => null,
  #        "hasActiveForeignPassport" => false,
  #        "nativeFullName" => "Иванов, Иван",
  #        "comments" => null,
  #        "administrator" => false,
  #        "it" => false,
  #        "engineer" => true,
  #        "gradeAsString" => "A1",
  #        "formattedPhone" => null,
  #        "socialCastContact" => null,
  #        "gitHubContact" => null,
  #        "location" => "Earth",
  #        "id" => 749,
  #        "familyName" => "Ivanov",
  #        "fullName" => "Ivan Ivanov",
  #        "position" => "Contractor",
  #        "phone" => null,
  #        "email" => "iivanov@domen.com",
  #        "skypeId" => null,
  #        "other" => null
  #     }
  #   }
  # }
  #
  def get_assignment(project_name)
    response = request_execute("/service/projects/" + project_name + "/assignment")

    assignments = Hash.new

    for assignment in JSON.parse(response)
      assignments[assignment["employee"]["username"]] = {
          :role => assignment["role"],
          :employee => assignment["employee"]
      }
    end
    assignments
  end
end