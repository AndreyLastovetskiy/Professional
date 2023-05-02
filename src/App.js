import { MemoryRouter, Routes, Route, Link } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { Context } from './hooks/context';
import Web3 from 'web3'
import abi from './abi.json'
import { useLocalStorage } from './hooks/localStorage';
import { Login } from './pages/login';
import { Logout } from './pages/logout';
import { SignUp } from './pages/signup';
import { NewPrivateRequestButton } from './components/newPrivateRequest';
import { ListPrivateRequest } from './pages/listPrivateRequest';
import { Index } from './pages/index';
import { BuyTokens } from './pages/buy';
import { Developers } from './pages/developers';

function App() {
  const [web3, setWeb3] = useState({})
  const [contract, setContract] = useState({})
  const [account, setAccount] = useLocalStorage('account', '')
  const [user, setUser] = useState({})
  const [balance, setBalance] = useState(0)

  const [currentPhase, setCurrentPhase] = useState('')
  const [timeSystem, setTimeSystem] = useState(0);
  const [role, setRole] = useState('')
  const [sumBalance, setSumBalance] = useState(0)

  const currentPhaseToString = (phase) => {
    switch (Number(phase)) {
      case 0: return "SEED";
      case 1: return "PRIVATE";
      case 2: return "PUBLIC";
    }
  }

  const roleToString = (role) => {
    switch (Number(role)) {
      case 0: return "USER";
      case 1: return "SEED PROVIDER";
      case 2: return "PRIVATE PROVIDER";
      case 3: return "PUBLIC PROVIDER";
      case 4: return "OWNER"
    }
  }

  const getInitialValues = async () => {
    if (!contract || !contract.methods) return
    const currentPhase = await contract.methods._getCurrentPhase().call()
    setCurrentPhase(currentPhaseToString(currentPhase));

    if (account.length) {
      const user = await contract.methods.getUserByAddress(account).call()
      setRole(roleToString(user.role))
      setUser(user)

      const balance = await web3.eth.getBalance(account)
      setBalance(balance)

      const sumOfAllTokens = await contract.methods.sumBalanceOf(account).call();
      setSumBalance(sumOfAllTokens);
    }
  }

  const initTimeSystem = async () => {
    if (!contract || !contract.methods) return;
    const currentTimeSystem = await contract.methods._getTimeSystem().call()
    setTimeSystem(currentTimeSystem);

    setInterval(() => {
      setTimeSystem(prev => Number(prev) + 1)
    }, 1000)
  }

  const increaseTimeDiff = async () => {
    await contract.methods.increaseTimeDiff(60).send({ from: process.env.REACT_APP_DEFAULT_ACCOUNT })
    setTimeSystem(prev => prev += 60)
  }

  useEffect(() => {
    const newWeb3 = new Web3('http://localhost:8545')
    const newContract = new newWeb3.eth.Contract(abi, process.env.REACT_APP_CONTRACT_ADDRESS)

    setWeb3(newWeb3)
    setContract(newContract)
  }, [])

  useEffect(() => {
    getInitialValues()
  }, [contract, account, web3])

  useEffect(() => {
    initTimeSystem()
  }, [contract])

  return (
    <Context.Provider value={{ web3, contract, accountState: [account, setAccount], userState: [user, setUser] }}>
      <MemoryRouter>
        <header style={{ marginBottom: '30px' }}>
          <Link to='/'><h1>Crypto Monster</h1></Link>

          Current phase: <strong>{currentPhase}</strong><br />
          Current time of system life: <strong>{timeSystem}</strong> seconds<br />
          {account.length ?
            <>Current username: <strong>{user.username}</strong> | <Link to="/logout">Log Out</Link><br />
              Current role: <strong>{role}</strong><br />
              Current sum of all tokens: <strong>{sumBalance / (10 ** 12)} CMON</strong><br />
              Current ETH balance: <strong>{balance / (10 ** 18)} ETH</strong><br />
              <button onClick={increaseTimeDiff}>Increate Time System by 1 minute</button>
            </> :
            <>
              <Link to="/login">Log in</Link> | <Link to="/signup">Sign Up</Link>
            </>}
        </header>
        <Routes>
          <Route path='/' element={<Index />} index />
          <Route path='/signup' element={<SignUp />} />
          <Route path='/logout' element={<Logout />} />
          <Route path='/login' element={<Login />} />
          <Route path='/list-private-requests' element={<ListPrivateRequest />} />
          <Route path='/buy' element={<BuyTokens />} />
          <Route path='/developers' element={<Developers />} />
        </Routes>
        <footer>
          <Link to='/developers'>Developers</Link>
        </footer>
      </MemoryRouter>
    </Context.Provider>
  );
}

export default App;
