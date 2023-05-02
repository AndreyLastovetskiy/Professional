import { Link } from "react-router-dom"
import { useContext } from "../../hooks/context"
import { NewPrivateRequestButton } from "../../components/newPrivateRequest"

export const Index = () => {
    const { userState: [user], accountState: [account] } = useContext()

    return account &&
        <ul>
            {!user.allowedToBuyInPrivatePhase && <li>
                <NewPrivateRequestButton />
            </li>}

            {user.role === "2" && <li>
                <Link to='/list-private-requests'>List Private Requests</Link>
            </li>}

            <li><Link to='/buy'>Buy tokens</Link></li>
        </ul>
}