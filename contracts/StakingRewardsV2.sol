// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract StakingRewardsV2 is Initializable, ReentrancyGuardUpgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    IERC20Upgradeable private tokenStaked;
    IERC20Upgradeable private tokenRewarded;

    //<----UPGRADE-----
    uint256 constant rewardRate = 0.2 ether ;
    //-----UPGRADE---->
    uint256 private RPT; //当前累加值, Reward Per Token
    uint256 private updateTime;  //当前时间戳
    uint256 private totalSupply; //当前区间质押总量
    
    mapping(address => uint256) private userRPT; //更新用户的累加值
    mapping(address => uint256) private userRewards; //用户奖励累计
    mapping(address => uint256) private balances; //用户存入的tokenStaked


    function initialize(
        address _tokenStaked,
        address _tokenRewarded
    ) public initializer {
        __ReentrancyGuard_init();

        tokenStaked = IERC20Upgradeable(_tokenStaked); //BUSD
        tokenRewarded = IERC20Upgradeable(_tokenRewarded); //Zero2Hero
    }    

//================================================================

    //计算当前累加值
    function UpdateRPT() private view returns (uint256) {
        if(totalSupply == 0) {
            return RPT;
        }

        uint256 currentRPT = RPT.add(
                                        block.timestamp.sub(updateTime).mul(rewardRate)
                                            .div(totalSupply)
                                    );

        return  currentRPT;
    }

    //计算用户从上一次操作的奖励
    function Reward(address user) private view returns(uint256) {
        uint256 userReward = balances[user].mul(RPT.sub(userRPT[user])); //modifier先执行，所以第一次操作用户余额是0，奖励也是0

        return userReward;
    }

//================================================================

    //无论是Stake或Withdraw都会产生一次Update
    modifier Update(address user) {
        RPT = UpdateRPT(); //计算当前累加值
        updateTime = block.timestamp; //更新操作时间戳

        userRewards[user] = userRewards[user].add(Reward(user)); //用当前累加值与用户累加值计算<两次操作之间的奖励>

        userRPT[user] = RPT; //更新用户累加值
        _;
    }

//=================================================================
//Write

    //质押tokenStaked
    function Stake(uint256 amount) public nonReentrant Update (msg.sender) {
        require(amount > 0, "Cannot stake 0");
        amount = amount.mul(1 ether);
      
        tokenStaked.safeTransferFrom(msg.sender, address(this), amount);

        totalSupply = totalSupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
    }

    //取出tokenStaked
    function Withdraw(uint256 amount) public nonReentrant Update (msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(balances[msg.sender] >= amount, "Insufficent balance");
        amount = amount.mul(1 ether);
        
        tokenStaked.safeTransfer(msg.sender, amount);

        totalSupply = totalSupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
    }

    //获得tokenRewarded
    function GetReward() public nonReentrant {
        tokenRewarded.safeTransfer(msg.sender, userRewards[msg.sender]);

        userRewards[msg.sender] = 0;
    }

//=================================================================
//Read

    //此合约tokenRewarded余额
    function ContractBalance() public view returns (uint256) {
        uint256 amount = tokenRewarded.balanceOf(address(this));
        amount = amount / 1 ether;

        return amount;
    }

    function TotalSupply() public view returns (uint256) {
        uint256 amount = totalSupply;
        amount = amount / 1 ether;

        return amount;
    }

    function UserBalance(address user) public view returns (uint256) {
        uint256 amount = balances[user];
        amount = amount / 1 ether;

        return amount;
    }


    function UserRewards(address user) public view returns (uint256) {
        uint256 amount = userRewards[user];
        amount = amount / 1 ether;

        return amount;
    }


//=================================================================

//<----UPGRADE-----
    function DiceGame(uint256 guess, uint256 bet) public returns (uint256) {
        require(guess >= 1 && guess <= 6, "Guess must be between 1 and 6.");
        require(bet >= 100, "The bet must be greater than 100.");
        bet = bet.mul(1 ether);

        tokenRewarded.safeTransferFrom(msg.sender, address(this), bet);

        uint256 roll = uint256(keccak256(abi.encodePacked(block.timestamp))) % 6 + 1;

        if(guess == roll) {
            tokenRewarded.safeTransfer(msg.sender, bet.mul(6).sub(10 ether));
        } 

        return roll;
    }
//-----UPGRADE---->


}