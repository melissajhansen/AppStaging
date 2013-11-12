public with sharing class HelloWorld {
        public String name { get; set; }
        public String message { get; set; }
        public PageReference hello() {
                message = 'Hello, ' + name;
                return null;
        }
}