import { useState } from "react"

export const useLocalStorage = (key, initialValue) => {
    let value = localStorage.getItem(key)
    if(!value) {
        localStorage.setItem(key, initialValue)
        value = localStorage.getItem(key)
    }

    const [state, setState] = useState(value)

    const setValue = (newValue) => {
        setState(() => {
            localStorage.setItem(key, newValue);
            return newValue
        })

        return newValue
    }

    return [state, setValue]
}