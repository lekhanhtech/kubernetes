from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

def check_browser(browser):
  driver = webdriver.Remote(
    command_executor='http://selenium.example.org/wd/hub',
    desired_capabilities=getattr(DesiredCapabilities, browser)
  )
  driver.get("http://google.com")
  assert "google" in driver.page_source
  driver.quit()
  print("Browser %s checks out!" % browser)


check_browser("FIREFOX")
check_browser("CHROME")
