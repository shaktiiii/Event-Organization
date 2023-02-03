// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EventOrganization{
    //Structure for details of the event

    struct Event {
        address organizer;
        string name; 
        uint price; 
        uint date; 
        uint ticketcount;
        uint ticketRemaning;
        uint EventID;
    }

    
    // maping uint with a event 
        // THIS WILL GIVE A PERTICULAR ORGANIZER TO ORGANIZE N NUMBER OF EVENTS.
    mapping (uint => Event) public events;
    // nested mapping to hold tickets against a perticluar address
        // THIS SIGNIFES A PERSON CAN HOLD N NUMBER OF TICKETS OF N NUMBER FOR SHOWS 
    mapping (address => mapping(uint => uint)) internal Tickets;


    // state variable for eventid (nextID)
     
    uint internal nextID;

    // FUNCTION 
    //      CREATEING EVENT 
        // -take all the input for the struct 
        // -it requires the date to be more then the current timestamp. 
        // -it requires more than 0 ticket for the event.
        // -it will now add all the details from the parmeter to the event struct on the 0th index of the mapping by utilizing the initial value of the event id 
        // -it will add 1 in the event id so the next one
       
    function createEvent( string memory _name, uint _price , uint _date, uint _ticketCount) external {
        require(_date >block.timestamp, " PLESE GIVE A PROPER DATE FOR THE EVENT"); 
        require(_ticketCount > 0, " THE TICKET COUNT SHOULD BE MORE THAN 0 ");
        events[nextID] = Event(msg.sender, _name, _price , _date , _ticketCount, _ticketCount, nextID);
        nextID++ ; 
    }

    // Creating modifier to make the code more clean 
        // -it will requires to check the existence of the event 
        // -it will require the date of the event to be after the current block time 

    modifier eventStatus(uint _id){
        require(events[_id].date != 0, "Please enter a valid Event Details");
        require(events[_id].date > block.timestamp , "The event has already occured");
        _;

    }
    
    //      BUYING EVENT TICKET (payable function to receive funds ) 
        // -initialized and make a copy of the event in any other event id
        // -it requires the msg.value to be equal to the event price * the no of tickets required
        // -it requires to check whether the remaing tickets are more then required tickets 
        // -we will substract the quantity requried from the remaing tickets. 
        // -we will add the number of tickets to perticular show by using nested mapping.
    
    function buyTicket(uint _id, uint _quantity) external payable eventStatus(_id) {
        
        Event storage _event = events[_id];
        require(msg.value == _event.price*_quantity , "Please enter a valid Amount");
        require(_event.ticketRemaning >= _quantity, "Try for lower count or Tickets are already sold out");
        _event.ticketRemaning -= _quantity;
        Tickets[msg.sender][_id] += _quantity;
    }

    // TRANSFAR FUNCTION TO TRANSFER N NUMBER OF TICKTS TO X ADDRESS
        // -it will then check if the number of tickets are greater then the number of tickets to send.(by using the nexted mapping) 
        // -we will then substract the number of tickets to be sent from ther address 
        // -we will add the substracted tickets to the new given address

    function transferTicket(uint _id, uint _quantity, address _to) external eventStatus(_id){
        require(Tickets[msg.sender][_id] > _quantity, "You dont have enough Tickets");
        Tickets[msg.sender][_id] -= _quantity;
        Tickets[_to][_id] += _quantity;


    }

    // Remaing Ticket 
        // First we check if the event is there or Not 
        // We take event ID as input and the total tickets remaning 

    function RemaningTickets(uint _id) view public eventStatus(_id) returns(uint){ 
        return events[_id].ticketRemaning;
    }

}   

