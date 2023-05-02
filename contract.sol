// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract CMON is IERC20, IERC20Metadata {
    uint timeStart;
    uint timeDiff;

    enum Role {
        USER, SEED_PROVIDER, PRIVATE_PROVIDER, PUBLIC_PROVIDER, OWNER
    }

    enum Phase {
        SEED, PRIVATE, PUBLIC
    }

    mapping(address => 
            mapping(Phase => 
                    mapping(address => uint))
            ) allowances;

    address[3] providers;
    uint[3] phaseTimes;
    uint[3] phasePrices;

    uint totalTokenSupply = 10000000;
    uint seedTokens = totalTokenSupply * 1 / 10;
    uint privateTokens = totalTokenSupply * 3 / 10;
    uint publicTokens = totalTokenSupply * 6 / 10;

    struct User {
        address addr;
        string username;
        uint[3] phaseBalances;
        bytes32 passwordHash;
        Role role;
        bool allowedToBuyInPrivatePhase;
        bool exists;
    }
    mapping(address => User) users;
    mapping(string => address) usernames;
    string[] usernamesArray;

    struct PrivateRequest {
        address author;
        uint timestamp;
        bool reviewed;
        bool exists;
    }
    mapping(address => PrivateRequest) privateRequests;
    address[] privateRequestIds;

    address seedProvider = 0xf8ec9bfebB9D63862Ed9079ddfB21528dA5D7788;
    address privateProvider = 0x27477b0397d7CA99266cAaf1E4a7fa2Ff4f74C43;
    address publicProvider = 0x8f3f9211702286A5EF1eFAE6a3DA8aC49fe39346;

    address investor1 = 0xec546A1BB062Bc63529DEa603D42fE9eAE9882FF;
    address investor2 = 0xFcae8c4118319b121E55295AAcbCDf301F979fc8;
    address bestfriend = 0x0469f2d9FA71969589cF18fa5C8b523829e4B0B2;

    constructor() 
    {
        timeStart = block.timestamp;

        phaseTimes[uint(Phase.SEED)] = 5 * 60;
        phaseTimes[uint(Phase.PRIVATE)] = phaseTimes[uint(Phase.SEED)] + 10 * 60;

        phasePrices[uint(Phase.SEED)] = 0;
        phasePrices[uint(Phase.PRIVATE)] = 7500000; // 0.00075 CMON
        phasePrices[uint(Phase.PUBLIC)] = 10000000; // 0.001 CMON

        providers[uint256(Phase.SEED)] = seedProvider;
        providers[uint256(Phase.PRIVATE)] = privateProvider;
        providers[uint256(Phase.PUBLIC)] = publicProvider;

        uint256[3] memory seedPhaseBalances = [seedTokens, 0, 0];
        users[seedProvider] = User(seedProvider, "seedProvider", seedPhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.SEED_PROVIDER, false, true);
        usernames["seedProvider"] = seedProvider;
        usernamesArray.push("seedProvider");

        uint256[3] memory privatePhaseBalances = [0, privateTokens, 0];
        users[privateProvider] = User(privateProvider, "privateProvider", privatePhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.PRIVATE_PROVIDER, true, true);
        usernames["privateProvider"] = privateProvider;
        usernamesArray.push("privateProvider");

        uint256[3] memory publicPhaseBalances = [0, 0, publicTokens];
        users[publicProvider] = User(publicProvider, "publicProvider", publicPhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.PUBLIC_PROVIDER, false, true);
        usernames["publicProvider"] = publicProvider;
        usernamesArray.push("publicProvider");

        uint256[3] memory investor1PhaseBalances = [uint(300000000000000000), 0, 0];
        users[investor1] = User(investor1, "Investor1", investor1PhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.USER, true, true);
        usernames["Investor1"] = investor1;
        usernamesArray.push("Investor1");

        uint256[3] memory investor2PhaseBalances = [uint(400000000000000000), 0, 0];
        users[investor2] = User(investor2, "Investor2", investor2PhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.USER, true, true);
        usernames["Investor2"] = investor2;
        usernamesArray.push("Investor2");

        uint256[3] memory bestfriendsPhaseBalances = [uint(200000000000000000), 0, 0];
        users[bestfriend] = User(bestfriend, "Bestfriend", bestfriendsPhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.USER, true, true);
        usernames["Bestfriend"] = bestfriend;
        usernamesArray.push("Bestfriend");

        uint256[3] memory defaultPhaseBalances = [uint(0), 0, 0];
        users[msg.sender] = User(msg.sender, "Owner", defaultPhaseBalances, 0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107, Role.OWNER, true, true);
        usernames["Owner"] = msg.sender;
        usernamesArray.push("Owner");
    }

    modifier onlyOwner() {
        require(users[msg.sender].role == Role.OWNER, "This function is allowed only for owner");
        _;
    }

    modifier onlyPrivateProvider() {
        require(users[msg.sender].role == Role.PRIVATE_PROVIDER, "This function is allowed only for private provider");
        _;
    }

    function _getTimeSystem() public view returns (uint) {
        return (block.timestamp + timeDiff) - timeStart;
    }

    function _getCurrentPhase() public view returns (Phase) {
        uint timeSystem = _getTimeSystem();
        if(timeSystem <= phaseTimes[uint(Phase.SEED)]) return Phase.SEED;
        else if(timeSystem <= phaseTimes[uint(Phase.PRIVATE)]) return Phase.PRIVATE;
        return Phase.PUBLIC;
    }

    function _keccak256(string memory toHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(toHash));
    }

    function name() external pure returns (string memory) {
        return "CryptoMonster";
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external pure returns (string memory) {
        return "CMON";
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external pure returns (uint8) {
        return 12;
    }

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256) {
        return totalTokenSupply;
    }

    function getUserByAddress(address addr) external view returns (User memory) {
        return users[addr];
    }

    function getUserByUsername(string memory username) external view returns (User memory) {
        return users[usernames[username]];
    }

    function newPrivateRequest() external returns (bool) {
        require(!privateRequests[msg.sender].exists, "You've already sent request to private provider");
        PrivateRequest memory privateRequest = PrivateRequest(msg.sender, block.timestamp, false, true);
        privateRequests[msg.sender] = privateRequest;
        
        return true;
    }

    function operatePrivateRequest(address sender, bool toApprove) external returns (bool) {
        require(privateRequests[sender].exists, "This user haven't sent any requests");
        privateRequests[sender].reviewed = true;
        if(toApprove) users[sender].allowedToBuyInPrivatePhase = true;

        return true;
    }

    function getPrivateRequestIds() external onlyPrivateProvider view returns (address[] memory) {
        return privateRequestIds;
    }

    function getPrivateRequest(address _sender) external onlyPrivateProvider view returns (PrivateRequest memory) {
        require(privateRequests[_sender].exists, "This user haven't sent any private requests");
        return privateRequests[_sender];
    }

    function changePrivateTokenPrice(uint newPrice) external onlyPrivateProvider returns (bool) {
        phasePrices[uint(Phase.PRIVATE)] = newPrice;
        return true;
    }

    function increaseTimeDiff(uint amountOfTime) external onlyOwner returns (bool) {
        timeDiff += amountOfTime;
        return true;
    }

    function buy(uint amount) external payable returns(bool) {
        Phase currentPhase = _getCurrentPhase();
        return _buy(currentPhase, amount);
    }

    function buyPhase(Phase phase, uint amount) external payable returns(bool) {
        return _buy(phase, amount);
    }

    /**
      *  Двухфакторную аутентификацию в рамках блокчейна Ethereum реализовать невозможно,
      *  поскольку все транзакции записываются в сеть (в том числе и аргументы, передающиеся
      *  в функции смарт-контракта), а значит, любая передача пароля в открытом виде будет также
      *  видна всем пользователям блокчейна, что препятствует проверке пароля при входе в аккаунт,
      *  поскольку для полноценной двухфактороной аутентификации мы должны записать в блокчейн время входа
      *  и был ли вход в принципе, что означает запись транзакции в блокчейн (а значит, и всех аргументов
      *  переданных в функцию входа в аккаунт, в том числе пароля - из-за чего мы вынуждены передавать
      *  исключительно хеш пароля, который доступен для просмотра всем, а значит смысла в подобной
      *  двухфактороной аутентификации нету)
      */
    function signUp(string memory username, bytes32 passwordHash) external returns(bool) {
        require(!users[msg.sender].exists, "You are already signed up");
        require(usernames[username] == address(0), "This username is already taken");
        
        uint[3] memory phaseBalances = [uint(0), 0, 0];
        users[msg.sender] = User(msg.sender, username, phaseBalances, passwordHash, Role.USER, false, true);
        usernames[username] = msg.sender;
        usernamesArray.push(username);

        return true;
    }

    // функция view, выполняется на стороне клиента - данные о 
    // переданных в функцию аргументах не записываются в блокчейн
    function checkPasswordHash(string memory username, string memory password) external view returns (bool) {
        require(usernames[username] != address(0), "User under this username doesn't exist");
        require(users[usernames[username]].passwordHash == _keccak256(password), "Wrong password");

        return true;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return users[account].phaseBalances[uint(_getCurrentPhase())];
    }

    function sumBalanceOf(address account) external view returns (uint) {
        return _sumOfPhaseBalances(users[account].phaseBalances);
    }

    function detailedBalanceOf(address account) external view returns (uint[3] memory) {
        return users[account].phaseBalances;
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        Phase currentPhase = _getCurrentPhase();
        return _transfer(to, currentPhase, amount);
    }

    function phaseTransfer(address to, Phase phase, uint amount) external returns (bool) {
        return _transfer(to, phase, amount);
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        Phase currentPhase = _getCurrentPhase();
        return _allowance(owner, currentPhase, spender);
    }

    function phaseAllowance(address owner, Phase phase, address spender) external view returns (uint) {
        return _allowance(owner, phase, spender);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        Phase currentPhase = _getCurrentPhase();
        return _approve(spender, currentPhase, amount);
    }

    function phaseApprove(address spender, Phase phase, uint256 amount) external returns (bool) {
        return _approve(spender, phase, amount);
    }

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        Phase currentPhase = _getCurrentPhase();
        return _transferFrom(from, to, currentPhase, amount);
    }

    function phaseTransferFrom(address from, address to, Phase phase, uint amount) external returns (bool) {
        return _transferFrom(from, to, phase, amount);
    }

    function _buy(Phase phase, uint amount) internal returns (bool) {
        User memory sender = users[msg.sender];
        require(phase != Phase.SEED, "You can't buy tokens in seed phase");
        require(phase != Phase.PRIVATE || sender.allowedToBuyInPrivatePhase, "You can't buy tokens in private phase, please send request to private provider");

        uint phasePrice = phasePrices[uint(phase)];
        require(msg.value == amount * phasePrice, "Send exact amount of eth that is required to buy such amount of CMON");
        
        users[providers[uint(phase)]].phaseBalances[uint(phase)] -= amount;
        users[msg.sender].phaseBalances[uint(phase)] += amount;

        return true;
    }

    function _transferFrom(address from, address to, Phase phase, uint256 amount) internal returns(bool) {
        require(amount > 10 ** 10, "Please transfer more then 10^10 CMON to prevent DoS attack");

        uint userPhaseAllowance = _allowance(from, phase, to);
        require(userPhaseAllowance >= amount, "Current allowance for this user is not enough to transfer that amount of CMON");

        allowances[from][phase][to] -= amount;
        users[to].phaseBalances[uint(phase)] += amount;

        return true;
    }

    function _approve(address spender, Phase phase, uint256 amount) internal returns (bool) {
        User memory sender = users[msg.sender];
        require(sender.phaseBalances[uint(phase)] >= amount, "You don't have enough CMON to allow");

        allowances[msg.sender][phase][spender] += amount;
        users[msg.sender].phaseBalances[uint(phase)] -= amount;
        return true;
    }

    function _allowance(address owner, Phase phase, address spender) internal view returns (uint256) {
        return allowances[owner][phase][spender];
    }

    function _transfer(address to, Phase phase, uint amount) internal returns (bool) {
        require(amount >= 10**10, "Please send more then 10^10 CMON to prevent DoS attack");
        
        User memory sender = users[msg.sender];
        require(sender.phaseBalances[uint(phase)] >= amount, "You don't have enough CMON in current phase to transfer");

        users[msg.sender].phaseBalances[uint(phase)] -= amount;
        users[to].phaseBalances[uint(phase)] += amount;

        return true;
    }

    function _sumOfPhaseBalances(uint[3] memory phaseBalances) internal pure returns(uint) {
        uint result;
        for(uint i; i < phaseBalances.length; i++) {
            result += phaseBalances[i];
        }
        return result;
    }
}