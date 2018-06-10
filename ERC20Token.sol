pragma solidity ^0.4.19;

/// @title build a ERC20 standard token
/// @notice You can use this contract for only the most basic simulation
/// @dev contract in general not secure
contract ERC20Token {

    function totalSupply() constant returns (uint256 supply) {}

    function balanceOf(address _owner) constant returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) returns (bool success) {}

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    function approve(address _spender, uint256 _value) returns (bool success) {}

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/// @ notice contract to implement the methods of the above contract
contract Token is ERC20Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /// @notice transfers tokens from msg.sender to given address
    /// @param _to destination address
    /// @param _value quantity of tokens to sender
    /// @return true if success
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    /// @notice transfer function specifying sender, need previous sender allowance with apporve function
    /// @param _from sender address
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
          balances[_to] += _value;
          balances[_from] -= _value;
          allowed[_from][msg.sender] -= _value;
          Transfer(_from, _to, _value);
          return true;
      } else { return false; }
    }

    /// @notice token balance of _owner
    /// @param _owner address to check balance
    /// @return balance of _owner
    function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
    }

    /// @notice sender approves transfer
    /// @param _spender address that approves the transfer of tokens
    /// @param _value quantity of approve tokens to transfer
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice read mapping of allowed transfers
    /// @return if _owner is allowed to transfer
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
    }

}

// @

contract TST is Token {

    /// @notice if ether is sent to this address, send it back.
    function () {
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;

    /// @notice constructor defining main parameters of the token
    function TST(
        ) {
        balances[msg.sender] = 100000;
        totalSupply = 100000;
        name = "Test";
        decimals = 18;
        symbol = "TST";
    }

    /// @ notice approves and then calls the receiving contract
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
