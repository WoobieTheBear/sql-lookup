import { Router } from 'express';
import UserRepo from '../repositories/user-repository.mjs';

export const router = new Router();

router.get('/users', async (req, res) => {
    const results = await UserRepo.find();
    res.send(results);
});
router.post('/users', async (req, res) => {
    const { body } = req;
    const result = await UserRepo.insert(body);
    res.send(result);
});
router.put('/users/:id', async (req, res) => {
    const { params: { id }, body } = req;
    const result = await UserRepo.update(id, body);
    if (result) {
        res.send(result);
    } else {
        res.sendStatus(404);
    }
});
router.get('/users/:id', async (req, res) => {
    const { params: { id } } = req;
    const result = await UserRepo.findById(id);
    if (result) {
        res.send(result);
    } else {
        res.sendStatus(404);
    }
});
router.delete('/users/:id', async (req, res) => {
    const { params: { id } } = req;
    const result = await UserRepo.delete(id);
    if (result) {
        res.send(result);
    } else {
        res.sendStatus(404);
    }
});
