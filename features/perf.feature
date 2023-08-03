Feature: Caldera performance run
  Background: Common steps
    Given "2" users
    And spawn rate is "1" user per second

  Scenario: Login to Genie
    Given a user of type "RestApi" load testing "$conf::caldera.host$"
    And log all requests
    And repeat for "2" iterations
    And value for variable "test" is "none"
    And value for variable "saved_search_id" is "none"
    And value for variable "data_version" is "none"
    And value for variable "database" is "BUSINESS"
    And value for variable "audience_card_id" is "none"
    And value for variable "AtomicRandomString.audience_name" is "%s%sZ%d%d0 | upper=True, count=3"
    # login
    Then post request to template "authenticate.j2" with name "authenticate" to endpoint "/ | content_type=json"
    """
    {
      "username": "env::AUTOMATION_USER",
      "password": "env::AUTOMATION_PASSWORD"
    }
    """
    Then save response payload "$.data.loginUsingPassword.accessToken" in variable "test"
    # audience list
    Then post request to template "audience_list.j2" with name "audience_list_old" to endpoint "/"
    """
    {
      "database_one": "CONSUMER",
      "database_two": "NEW_MOVER"
    }
    """
    And metadata "Authorization" is "Bearer {{ test }}"
    # tags list
    # Then post request "tags_list.j2.json" with name "tags_list" to endpoint "/"
    # And metadata "Authorization" is "Bearer {{ test }}"
    # audience insights
    Then post request to template "audience_insights.j2" with name "audience_insights" to endpoint "/"
    """
    {
      "recordset_id": "Search_DoNotDeleteCard"
    }
    """
    And metadata "Authorization" is "Bearer {{ test }}"
    # create audience by search
    Then post request to template "business_search.j2" with name "business_search" to endpoint "/ | content_type=json"
    """
    {
      "CitiesByState": "KYAustin,GAAustell",
      "StateProvince": "CA"
    }
    """
    And metadata "Authorization" is "Bearer {{ test }}"
    Then save response payload "$.data.search.savedSearch" in variable "saved_search_id"
    Then save response payload "$.data.search.dataVersion" in variable "data_version"
    And log message "{{ saved_search_id }}"
    And log message "{{ data_version }}"
    Then post request "audience_create_through_search.j2.json" with name "audience_create_through_search" to endpoint "/ | content_type=json"
    And metadata "Authorization" is "Bearer {{ test }}"
    Then save response payload "$.data.audienceCreateThroughSearch.audience.id" in variable "audience_card_id"
    # delete audience
    Then post request "delete_audience.j2" with name "delete_audience" to endpoint "/ | content_type=json"
    And metadata "Authorization" is "Bearer {{ test }}"
    # audience list
    Then post request to template "audience_list.j2" with name "audience_list_new" to endpoint "/"
    """
    {
      "database_one": "BUSINESS",
      "database_two": "NEW_BUSINESS"
    }
    """
    And metadata "Authorization" is "Bearer {{ test }}"
