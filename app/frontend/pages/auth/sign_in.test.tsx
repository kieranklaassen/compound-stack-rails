import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import SignIn from './sign_in'

// The page uses Inertia's Head/usePage/useForm, all of which need the Inertia
// app context. Mock them so the presentational form can be tested in isolation.
vi.mock('@inertiajs/react', () => ({
  Head: () => null,
  usePage: () => ({ props: { flash: { alert: 'Invalid email or password.' } } }),
  useForm: () => ({
    data: { email_address: '', password: '' },
    setData: vi.fn(),
    post: vi.fn(),
    processing: false,
  }),
}))

describe('SignIn page', () => {
  it('renders the email, password, and submit controls', () => {
    render(<SignIn />)

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument()
  })

  it('surfaces a server error prop from flash', () => {
    render(<SignIn />)

    expect(screen.getByRole('alert')).toHaveTextContent('Invalid email or password.')
  })
})
