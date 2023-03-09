pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/UniswapV2Swap.sol";

contract Uniswapv2Test is Test {

    UniswapV2Swap swap;
    IUniswapV2Router public swapRouter;

    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;

    uint24 public constant fee = 3000;

    address binanceUser = 0xDFd5293D8e347dFe59E90eFd55b2956a1343963d;
    address owner;
    address luckyUser;
    IERC20 public dai;
    IERC20 public usdc;
    IERC20 public weth;

    function setUp() public {
        owner = address(this);
        luckyUser = vm.addr(2);
        dai = IERC20(DAI);
        usdc = IERC20(USDC);
        weth = IERC20(WETH9);

        swapRouter = IUniswapV2Router(UNISWAP_V2_ROUTER);
        swap = new UniswapV2Swap(swapRouter);        
    }

    function testSwapSingleHopExactAmountInDAItoWETH() public {
        // msg.sender must approve this contract
        vm.startPrank(binanceUser);
        console.log("Binance User WETH9 beginning balance: ", weth.balanceOf(binanceUser));

        dai.approve(address(this), 1000 * 1e18);
        console.log("approved");

        uint256 amountIn = 1e18;        

        // Approve the router to spend DAI.
        dai.approve(address(swapRouter), amountIn);
        dai.approve(address(swap), amountIn);
        console.log("approved contract");

        uint amountOut = swap.swapSingleHopExactAmountIn(DAI, WETH9, amountIn, 0);
        console.log("Amount out: ${amountOut} : ", amountOut );
        console.log("Binance User WETH9 finishing balance: ", weth.balanceOf(binanceUser));

    }

    // Swap DAI -> WETH -> USDC
    function testSwapMultiHopExactAmountIn() public {
        // msg.sender must approve this contract
        vm.startPrank(binanceUser);
        console.log("Binance User USDC beginning balance: ", usdc.balanceOf(binanceUser));

        dai.approve(address(this), 1000 * 1e18);
        console.log("approved");

        uint256 amountIn = 1e18; 

        // Approve the router to spend DAI.
        dai.approve(address(swapRouter), amountIn);
        dai.approve(address(swap), amountIn);
        console.log("approved contract");

        address[] memory path;
        path = new address[](3);
        path[0] = DAI;
        path[1] = WETH9;
        path[2] = USDC;

        uint amountOut = swap.swapMultiHopExactAmountIn(DAI, path, amountIn, 0);
        console.log("Amount out: ${amountOut} : ", amountOut );
        console.log("Binance User USDC finishing balance: ", usdc.balanceOf(binanceUser));


    }
    

}