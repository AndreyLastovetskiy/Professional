import { useEffect } from "react"
import { useContext } from "../../hooks/context"

export const NewPrivateRequestButton = () => {
    const { contract, accountState: [account, setAccount], userState: [_user, setUser] } = useContext()

    const newPrivateRequest = async () => {
        try {
            await contract.methods.newPrivateRequest().send({ from: account })
            alert('Private phase request successfully sent. Press OK to proceed.')
        } catch (e) {
            console.error(e)
            alert(e)
        }
    }

    return <button onClick={newPrivateRequest}>Send private phase request</button>
}