import { useEffect, useState } from "react"
import { useContext } from "../../hooks/context"

export const ListPrivateRequest = () => {
    const { contract, web3, userState: [user], accountState: [account] } = useContext()
    const [requests, setRequests] = useState([])

    const getRequests = async () => {
        try {
            const requestIds = await contract.methods.getPrivateRequestIds().call({ from: account })
            const requests = await Promise.all(
                requestIds.map(
                    async id => {
                        const request = await contract.methods.getPrivateRequest(id).call({ from: account })
                        const user = await contract.methods.getUserByAddress(request.author).call({ from: account })
                        return { ...request, user }
                    }
                )
            )
            console.log(requestIds)

            setRequests(requests.filter(request => !request.reviewed))
        } catch (e) {
            alert(e)
            console.error(e)
        }
    }

    const operateRequest = async (sender, username, toApprove) => {
        try {
            await contract.methods.operatePrivateRequest(sender, toApprove).send({ from: account })
            alert(`Successfully ${toApprove ? 'approved' : 'declined'} request from ${username}. Press OK to proceed.`);
            setRequests(prev => (prev.filter(request => request.author !== sender)))
        } catch(e) {
            console.error(e)
            alert(e)
        }
    }

    const approveRequest = (sender, username) => operateRequest(sender, username, true)
    const declineRequest = (sender, username) => operateRequest(sender, username, false)

    useEffect(() => {
        getRequests()
    }, [])

    return <ol>
        {requests.length ? requests.map(request => <li>
            Sender: <strong>{request.user.username}</strong><br/>
            <button onClick={() => approveRequest(request.author, request.user.username)}>Approve</button>
            <button onClick={() => declineRequest(request.author, request.user.username)}>Decline</button>
        </li>) : <strong>There is no private phase requests</strong>}
    </ol>
}